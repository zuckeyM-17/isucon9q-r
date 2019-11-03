require 'json'
require 'uri'
require 'net/http'

require 'redis'

module Isucari
  class API
    class Error < StandardError; end

    ISUCARI_API_TOKEN = 'Bearer 75ugk2m37a750fwir5xr-22l6h4wmue1bwrubzwd0'

    class << self
      def reset_cache
        keys = redis_client.keys(shipment_key(reserve_id: '*'))
        if keys && keys.size > 0
          redis_client.del(*keys)
        end
      end

      def get_resp(reserve_id:)
        key = shipment_key(reserve_id: reserve_id)

        resp = redis_client.get(key)
        if resp
          JSON.parse(resp)
        else
          nil
        end
      end

      def set_resp(reserve_id:, val:)
        key = shipment_key(reserve_id: reserve_id)
        redis_client.set(key, val.to_json)
      end

      def del_resp(reserve_id:)
        key = shipment_key(reserve_id: reserve_id)
        redis_client.del(key)
      end

      private

      def shipment_key(reserve_id:)
        "shipments:#{reserve_id}"
      end

      def redis_client
        Thread.current[:redis] ||= ::Redis.new(host: ENV['REDIS_HOST'] || '127.0.0.1')
      end
    end

    def initialize(logger:, debug:)
      @user_agent = 'isucon9-qualify-webapp'
      @logger = logger
      @debug = debug
    end

    def payment_token(payment_url, param)
      uri = URI.parse("#{payment_url}/token")

      req = Net::HTTP::Post.new(uri.path)
      req.body = param.to_json
      req['Content-Type'] = 'application/json'
      req['User-Agent'] = @user_agent

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme == 'https'
      res = start_with_logging(http, req, __method__)

      if res.code != '200'
        raise Error, "status code #{res.code}; body #{res.body}"
      end

      JSON.parse(res.body)
    end

    def shipment_create(shipment_url, param)
      uri = URI.parse("#{shipment_url}/create")

      req = Net::HTTP::Post.new(uri.path)
      req.body = param.to_json
      req['Content-Type'] = 'application/json'
      req['User-Agent'] = @user_agent
      req['Authorization'] = ISUCARI_API_TOKEN

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme == 'https'
      res = start_with_logging(http, req, __method__)

      if res.code != '200'
        raise Error, "status code #{res.code}; body #{res.body}"
      end

      JSON.parse(res.body).tap do |resp|
        reserve_id = resp['reserve_id']
        reserve_time = resp['reserve_time']
        Isucari::API.set_resp(reserve_id: reserve_id, val: { reserve_time: reserve_time, status: 'initial' })
      end
    end

    def shipment_request(shipment_url, param)
      reserve_id = param[:reserve_id]
      Isucari::API.del_resp(reserve_id: reserve_id)

      uri = URI.parse("#{shipment_url}/request")

      req = Net::HTTP::Post.new(uri.path)
      req.body = param.to_json
      req['Content-Type'] = 'application/json'
      req['User-Agent'] = @user_agent
      req['Authorization'] = ISUCARI_API_TOKEN

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme == 'https'
      res = start_with_logging(http, req, __method__)

      if res.code != '200'
        raise Error, "status code #{res.code}; body #{res.body}"
      end

      res.body
    end

    def shipment_status(shipment_url, param)
      reserve_id = param[:reserve_id]

      v = Isucari::API.get_resp(reserve_id: reserve_id)
      if v
        @logger.info("cache hit for #{reserve_id}")
        return v
      end


      uri = URI.parse("#{shipment_url}/status")

      req = Net::HTTP::Post.new(uri.path)
      req.body = param.to_json
      req['Content-Type'] = 'application/json'
      req['User-Agent'] = @user_agent
      req['Authorization'] = ISUCARI_API_TOKEN

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme == 'https'
      res = start_with_logging(http, req, __method__)

      if res.code != '200'
        raise Error, "status code #{res.code}; body #{res.body}"
      end

      JSON.parse(res.body).tap do |ret|
        if ret['status'] == 'done'
          Isucari::API.set_resp(reserve_id: reserve_id, val: ret)
          @logger.info("cache saved!")
        end
      end
    end

    private

    def start_with_logging(http, req, name)
      if @debug
        http.start do
          beg = Time.now.to_f
          res = http.request(req)
          now = Time.now.to_f
          ms = (now - beg) * 1000
          @logger.info("#{name} http took #{ms.to_i}ms")
          res
        end
      else
        http.request(req)
      end
    rescue => e
      @logger.error(e)
      raise
    end
  end
end

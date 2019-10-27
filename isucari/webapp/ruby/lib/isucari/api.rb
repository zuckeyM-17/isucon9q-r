require 'json'
require 'uri'
require 'net/http'

module Isucari
  class API
    class Error < StandardError; end

    ISUCARI_API_TOKEN = 'Bearer 75ugk2m37a750fwir5xr-22l6h4wmue1bwrubzwd0'

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

      JSON.parse(res.body)
    end

    def shipment_request(shipment_url, param)
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

      JSON.parse(res.body)
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

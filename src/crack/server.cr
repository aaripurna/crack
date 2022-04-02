require "http/server"
require "logger"
require "./request"
require "./response"
require "./application"

module Crack
  class Server
    getter :applications

    @applications : Array(Crack::Application::Base)

    def initialize(@port : Int32, @use_cookie : Bool = true)
      @applications = Array(Crack::Application::Base).new()
    end

    def serve
      log = Logger.new(STDOUT)
      log.level = Logger::INFO

      log.info("Starting server on port #{@port}" )

      server = HTTP::Server.new do |context|

        request = Crack::Request.new(
          context.request.method,
          context.request.resource,
          context.request.headers,
          context.request.body,
          context.request.version
        )

        log.info("Request #{request.method} #{request.path} #{request.query} #{request.version}")

        response = Crack::Response.new(200, HTTP::Headers.new, Array(String).new, cookies: context.request.cookies)

        application = Application::Caller.new(@applications)

        request, response = application.call(request, response)

        context.response.status = HTTP::Status.new(response.status)

        context.response.headers.merge! response.headers

        if @use_cookie
          response.cookies.each do |cookie|
            cookie.http_only = true
            context.response.cookies << cookie
          end
        end

        context.response.print response.body
      end

      server.bind_tcp @port
      server.listen
    end
  end
end

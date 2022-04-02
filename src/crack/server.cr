require "http/server"
require "logger"
require "./request"
require "./response"
require "./application"

module Crack
  class Server
    getter :applications

    @applications : Array(Crack::Application::Base)

    def initialize(@port : Int32)
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

        response = Crack::Response.new(200, Hash(String, String).new, Array(String).new)

        application = Application::Caller.new(@applications)

        request, response = application.call(request, response)

        context.response.status = HTTP::Status.new(response.status)

        headers = response.headers.each do |key, value|
          context.response.headers[key] = value
        end
        context.response.print response.body
      end

      server.bind_tcp @port
      server.listen
    end
  end
end

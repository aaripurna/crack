require "./application"
require "./response"
require "./request"
require "mime"

module Crack
  class Static < Application::Handler
    def initialize(@asset_path : String, @request_prefix : String, @allowed_assets : Array(String))
      super()
    end

    def handle(request : Request, response : Response) : Tuple(Request, Response)
      unless path_allowed?(request.path)
        return { request, response }
      end


      file = file(request.path)

      if file.nil?
        response.status = 404
        return { request, response }
      end

      response.body = [file[0]]
      response.headers.merge!({ "Content-Type" => file[1] })

      continue = false

      { request, response }
    end

    def file(request_path) : Tuple(String, String) | Nil
      files = Dir["#{@asset_path}/*"].reject { |f| @allowed_assets.none?(f.split(".").last) }
      file_name = files.find { |f| "#{@request_prefix}#{f.split(@asset_path).last}" == request_path }

      return nil if file_name.nil?

      file = File.open(file_name)
      content = file.gets_to_end
      file.close

      {content, MIME.from_filename(file_name)}
    end

    def path_allowed?(request_path)
      request_path.gsub(/^\/|\/$/, "").starts_with?(@request_prefix.gsub(/^\/|\/$/, ""))
    end
  end
end

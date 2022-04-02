require "http/client"

module Crack
  class Response
    class Message
      setter :code, :detail
      getter :code, :detail

      def initialize(@code : String, @detail : String)
      end
    end

    getter :status, :headers, :messages, :cookies
    setter :body, :status, :messages

    def initialize(@status : Int32,
                  @headers : HTTP::Headers,
                  @body : Array(String),
                  @messages : Array(Message) = Array(Message).new,
                  @cookies : HTTP::Cookies = HTTP::Cookies.new)
    end

    def content_type
      @headers["Content-Type"] || "text/plain"
    end

    def body
      @body.join("\r\n")
    end
  end
end

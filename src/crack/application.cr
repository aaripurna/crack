require "./request"
require "./response"

module Crack
  module Application
    abstract class Base
      abstract def handle(request : Request, response : Response) : Tuple(Request, Response)
      abstract def next_handler=(handler : self)
      abstract def call(request : Request, response : Response) : Tuple(Request, Response)
    end

    class Handler < Base
      def handle(request : Request, response : Response) : Tuple(Request, Response)
        { request, response }
      end

      def next_handler=(handler : self)
        @next_handler = handler
      end

      def call(request : Request, response : Response) : Tuple(Request, Response)
        request, response = handle(request, response)

        return { request, response} unless @next_handler

        @next_handler.not_nil!.call(request, response)
      end
    end

    class Caller
      def initialize(@middlewares : Array(Base))
      end

      def add(middleware : Base)
        @middlewares.push(middleware)
      end

      def call(request : Request, response : Response) : Tuple(Request, Response)
        middleware = @middlewares.reduce(nil) do |memo, current|
          unless memo
            next current
          end

          memo.next_handler = current
          current
        end

        return { request, response } unless middleware

        middleware.call(request, response)
      end
    end
  end
end

require "./spec_helper"
require "json"

class BooMiddleWare < Crack::Middleware::Handler
  def handle(request : Crack::Request, response : Crack::Response) : Tuple(Crack::Request, Crack::Response)
    response.headers["Content-Type"] = "application/json"
    response.body = [{"hello" => "nawa"}.to_json]

    { request, response }
  end
end

describe Crack::Server do
  describe "#server" do
    it "should server" do
      server = Crack::Server.new(3030).tap do |config|
        config.applications << BooMiddleWare.new
      end

      server.serve
    end
  end
end

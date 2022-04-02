require "./spec_helper"
require "json"

class BooMiddleWare < Crack::Application::Handler
  def handle(request : Crack::Request, response : Crack::Response) : Tuple(Crack::Request, Crack::Response)
    response.headers["Content-Type"] = "text/html"
    response.body = [
      <<-HTML
        <!DOCTYPE html>
        <html lang="en">
        <head>
            <meta charset="UTF-8">
            <meta http-equiv="X-UA-Compatible" content="IE=edge">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Document</title>
            <script src="assets/main.js"></script>
            <link rel="stylesheet" href="assets/main.css">
        </head>
        <body>
          <img src="assets/robot.png" alt="Man">
        </body>
        </html>
      HTML
    ]

    { request, response }
  end
end

describe Crack::Server do
  describe "#server" do
    it "should server" do
      server = Crack::Server.new(3030).tap do |config|
        config.applications << BooMiddleWare.new
        config.applications << Crack::Static.new(asset_path: File.expand_path("spec/assets"), request_prefix: "/assets", allowed_assets: ["js", "css", "jpg", "png", "ico"])
      end

      server.serve
    end
  end
end

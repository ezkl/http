require 'webrick'

class ExampleService < WEBrick::HTTPServlet::AbstractServlet
  PORT = 65432

  def do_GET(request, response)
    case request.path
    when "/"
      response.status = 200

      case request['Accept']
      when 'application/json'
        response['Content-Type'] = 'application/json'
        response.body = '{"json": true}'
      else
        response['Content-Type'] = 'text/html'
        response.body   = "<!doctype html>"
      end
    when "/proxy"
      response.status = 200
      response.body     = "Proxy!"
    else
      response.status = 404
    end
  end

  def do_POST(request, response)
    case request.path
    when "/"
      if request.query['example'] == 'testing'
        response.status = 200
        response.body   = "passed :)"
      else
        response.status = 400
        response.body   = "invalid! >:E"
      end
    else
      response.status = 404
    end
  end

  def do_HEAD(request, response)
    case request.path
    when "/"
      response.status = 200
      response['Content-Type'] = 'text/html'
    else
      response.status = 404
    end
  end
end

ExampleServer = WEBrick::HTTPServer.new(:Port => ExampleService::PORT, :AccessLog => [])
ExampleServer.mount "/", ExampleService

t = Thread.new { ExampleServer.start }
trap("INT")    { ExampleServer.shutdown; exit }

Thread.pass while t.status and t.status != "sleep"



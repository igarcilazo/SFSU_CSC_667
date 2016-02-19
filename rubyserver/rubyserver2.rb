require 'socket'
require 'thread'


class SimpleServer
  attr_reader :session

  DEFAULT_PORT = 5666

  def initialize(session={})
    @session = session

  end

  def start
    loop do
      puts "Opening server socket to listen for connections"
      session = server.accept

      # Just to make the responses a little different...
      puts "Received connection, waiting for one second"
      sleep(1)

      puts "Writing message"
      session.puts "The current time is #{Time.now}"
      parse(session)

      session.close
    end
  end


  def parse session
    request = session.gets
    print "request: ", request
    print "---------------------------\n"

    fullpath = request.split(" ")
    path, query = fullpath[1].split("?")
    print path,"\n"
    print "Verb: ", "'",fullpath[0],"'","\n"
    print "Path: ", "'",fullpath[1],"'","\n"
    print "Query:", "'",query,"'","\n"
    print "Version:", "'",fullpath[2],"'","\n"
    headers = ""
    while (line = session.gets) != "\r\n"
      headers << line
    end
    puts headers


    if fullpath[1] == "/"
    #respond sample
    @session.puts "HTTP/1.1 200 OK"
    @session.puts "content-type: text/html"
    @session.puts ""
    myfile = IO.readlines("public/index.html")#read htmlfile
    #@session.puts(Time.now.ctime) # Send the time to the client
    @session.puts myfile#post html
    else 
      myfile = IO.readlines("public", path)#read htmlfile
        #@session.puts(Time.now.ctime) # Send the time to the client
        @session.puts myfile#post html
    end


    

    
    #request[:path], request[:verb], request[:query_string] = parse_resource(headers.shift).values_at(:path, :verb, :query_string)
    # request[:headers] = parse_headers(headers)
    # request[:body] = read_body(request, connection)
    # puts request
    # return request
  end



  def server
    @server ||= TCPServer.open(session.fetch(:port, DEFAULT_PORT))
  end
end
SimpleServer.new.start
require 'socket' # allows use of TCPServer & TCPSocket classes

DEFAULT_PORT = 56790

class WebServer
  attr_reader :options, :socket
  
  def initialize(options={})
    @options = options
  end
  
  def start
    loop do
      puts "Opening server socket to listen for connections"
      @socket = server.accept # open socket, wait until client connects
      
      puts "Received connection"
      Request.new(@socket).parse
      @socket.puts Response.new.to_s
      
      @socket.close # terminate connection
    end
  end
  
  # TCPServer represents a TCP/IP server socket
  def server
    @server ||= TCPServer.open(options.fetch('localhost', DEFAULT_PORT))
  end
end

# receives a stream in constructor, & parses content into members
class Request
  attr_reader :verb, :uri, :query, :version, :headers, :body, :session
  
  def initialize(stream)
    @session = stream
  end
  
  def parse
    request = @session.gets
    print "request: ", request
    
    fullpath = request.split(" ")
    path, query = fullpath[1].split("?")
    
    @body    = "body"
    @verb    = fullpath[0]
    @uri     = fullpath[1]
    @query   = query
    @version = fullpath[2]
    @headers = ""
    while (line = @session.gets) != "\r\n"
      @headers << line ### HEADERS SHOULD BE HASH (FIX LATER) ###
    end
    
    puts headers
    print "\r\n" # blank line
    puts "#{@body}"
    
  end
end

class Response # generates generic OK response to send to the client
  attr_reader :version, :response_code, :response_phrase, :headers, :body
  
  def initialize
    @body            = "body"
    @version         = "1.1"
    @response_code   = "200"
    @response_phrase = "OK"
    @headers         ={"Content-Type" => "text/plain",
                       "Content-Length" => "#{@body.bytesize}",
                       "Connection" => "close"}
  end
  
  def to_s
    return "#{@version} #{@response_code} #{@response_phrase}\r\n" +
           "Content-Type: #{@headers["Content-Type"]}\r\n" +
           "Content-Length: #{@headers["Content-Length"]}\r\n" +
           "Connection: #{@headers["Connection"]}\r\n" +
           "\r\n" +
           "#{@body}\r\n"
  end
end

WebServer.new.start
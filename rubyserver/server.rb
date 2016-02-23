require 'socket' # allows use of TCPServer & TCPSocket classesH
require 'thread'

#DEFAULT_PORT = 8999

class WebServer
  attr_reader :options, :socket
  
  def initialize(options={})
    @options = options
	
    #Open webserver configuration and mime types
    @httpd = HttpdConf.new(File.open("config/httpd.conf", "r").read())
    #@mimefile = File.open("config/mime.types", "r")
  end
  
  def start
    @portnumber = @httpd.port

    loop do
	  puts "\n-----------------------------------------------"
      puts "Opening server socket to listen for connections"
      @socket = server.accept # open socket, wait until client connects
      
	  Thread.new(@socket) do |newsocket| #Thread for every session
        puts "Received connection\n"
        Request.new(newsocket).parse
        newsocket.puts Response.new.to_s
        
        newsocket.close # terminate connection
      end
    end
  end
  
  # TCPServer represents a TCP/IP server socket
  def server
    @server ||= TCPServer.open(options.fetch('localhost', @portnumber))
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
    @headers = Hash.new
    
    while (header = @session.gets) != "\r\n"
      key, value = header.split(": ")
      @headers.store(key, value)
    end
    
    @headers.each do |key, value|
      puts "#{key}: #{value}"
    end
    print "\r\n" # blank line
    puts "#{@body}"
    
  end
end

class Response # generates generic OK response to send to the client
  attr_reader :version, :response_code, :response_phrase, :headers, :body
  
  def initialize
    @body            = "body"
    @version         = "HTTP/1.1"
    @response_code   = "200"
    @response_phrase = "OK"
    @headers         ={"Content-Type" => "text/plain",
                       "Content-Length" => "#{@body.bytesize}",
                       "Connection" => "close"}
  end
  
  def to_s
    s = "\r\n#{@version} #{@response_code} #{@response_phrase}\r\n"

    @headers.each do |key, value|
      s += "#{key}: #{value}\r\n"
    end
    s += "\r\n" # blank line
    s += "#{@body}\r\n"
    
    return s
  end
end

class HttpdConf 
    def initialize(httpdConfig)
      @config = httpdConfig.split("\n")
      @httpdhash = {}
    end
    def root
      @httpdhash[:root] = find("ServerRoot")
    end
    def docRoot
      @httpdhash[:docRoot] = find("DocumentRoot")
    end
    def port
      @httpdhash[:port] = find("port").to_i
    end
    def log
      @httpdhash[:log] = find("LogFile")
    end
    def errorlog
      @httpdhash[:errorlog] = find("ErrorLogFile")
    end
    def find(resource)
      keyword = ""
      @config.each do |line|
        if line.include? resource
          keyword = line.split(" ")
          break
        end
      end
      keyword = keyword[1]
    end
  end

WebServer.new.start
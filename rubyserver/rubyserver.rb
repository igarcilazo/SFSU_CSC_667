require 'thread'
require 'socket'

class RequestHandler
	def initialize(session)
		@session = session#global session instance variable

    # Set up WebServer's configuration files and logger here
    # Do any preparation necessary to allow threading multiple requests
    #@httpd = HttpdConf.new(File.open('config/httpd.conf', "r").read())
    #@mime_type_file = File.open("config/mime.types", "r")
  end

	#magic starts here
	def process
    
		# while @session.gets.chop.length != 0 
		# end
		
    parse(@session)
    #parse_request
    #request = @session.gets
    #split_requestArray = @session.split()
    #@piece1 = split_requestArray[0]
    #if == @piece1 == "something"
    # .....
    #respond sample
		# @session.puts "HTTP/1.1 200 OK"
		# @session.puts "content-type: text/html"
		# @session.puts ""
		# #@session.puts "<html><body>HELLO WORLD</body></html>"#basic respond
		# myfile = IO.readlines("respond.html")#read htmlfile
		# #@session.puts(Time.now.ctime) # Send the time to the client
		# @session.puts myfile#post html
	@session.close#done serving the page so page stop spinning
	end
  
  private

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
      myfile = IO.readlines(file)#read htmlfile
        #@session.puts(Time.now.ctime) # Send the time to the client
        @session.puts myfile#post html
    end


    

    
    #request[:path], request[:verb], request[:query_string] = parse_resource(headers.shift).values_at(:path, :verb, :query_string)
    # request[:headers] = parse_headers(headers)
    # request[:body] = read_body(request, connection)
    # puts request
    # return request
  end
    
  # def parse_resource(resource)
  #   verb, full_path = resource.split(" ")
  #   path, query_string = full_path.split("?")
  #   return { path: path, verb: verb, query_string: query_string }
  # end

  # def read_headers(connection)
  #   headers = ""

  #   while (line = connection.gets) != "\r\n"
  #     headers << line
  #   end
  #   return headers
  # end

  # def parse_headers(headers)
  #   return headers.reduce({}) do |parsed, line|
  #     k, v = line.split(": ")
  #     parsed[k] = v
  #     parsed
  #   end
  # end

  # def read_body(request, connection)
  #   body = ""

  #   if (body_length = request[:headers]["Content-Length"])
  #     body << connection.read(body_length.to_i)
  #   end
  #   puts body
  #   return body
  # end


  #     request = HTTPRequest.parse(line)
  #     line_array = line.split()
  #     @raw = line_array[1]
  #     @raw = "index.html" if @raw == "/"
  #     @file = File.open("public_html/" + @raw)
  #     @content = @file.read()
  #     @session.print "HTTP/1.1"
  #     arr = @raw.split(".")
  #     extension = arr[1]
  #     puts "Localhost: " + @port_number.to_s
  #     @mime_type = MimeTypes.new(@mime_type_file)
  #     type = @mime_type.for_extension(extension)
  #     puts "Content-Type: " + type
  #     puts "Content-Length: " + @content.length.to_s
  #     puts type.gsub(type, "")
  #     if type.include?("image")
  #       arr = @raw.split("/")
  #       puts arr.last
  #     else
  #       puts @content
  #     end
  #     puts
  #     @session.print @content

  #   end
  
  

end


server = TCPServer.new("0.0.0.0", "5056")#magic happens watch for a http request to comein
while (session = server.accept)#session accepted spin a thread
  Thread.new(session) do |newSession|#thread to launch in every session
    RequestHandler.new(newSession).process#call request handler
  end
end


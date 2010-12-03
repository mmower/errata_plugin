require 'digest/sha1'

module Errata
  
  class Erratum
    
    VALID_ENV = [
        "SERVER_NAME",
        "HTTP_CACHE_CONTROL",
        "HTTP_ACCEPT",
        "HTTP_HOST",
        "HTTP_USER_AGENT",
        "REQUEST_PATH",
        "SERVER_PROTOCOL",
        "HTTP_ACCEPT_LANGUAGE",
        "REMOTE_ADDR",
        "PATH_INFO",
        "SERVER_SOFTWARE",
        "SCRIPT_NAME",
        "HTTP_VERSION",
        "REQUEST_URI",
        "GATEWAY_INTERFACE",
        "HTTP_CONNECTION",
        "HTTP_ACCEPT_ENCODING",
        "QUERY_STRING"
      ]
    
    attr_reader :error
    attr_reader :time
    attr_reader :sha1
    attr_reader :server_port
    attr_reader :request
    
    def initialize( error, request )
      @error       = error
      @time        = Time.now
      @server_port = Integer( request.env["SERVER_PORT"] || 0 )
      @request     = request
      @sha1        = Digest::SHA1.hexdigest( "#{@time}-#{@error.message}-#{@parameters.inspect}")
    end
    
    def extract_headers( headers )
      headers.inject( {} ) do |hash,pair|
        name,value = pair
        if name.match( /HTTP_/ )
          name = name.sub( "HTTP_", "" ).split( '_' ).collect { |_| _.capitalize }.join( '-' )
          hash[name] = value.to_s
        end
        hash
      end
    end
    
    def to_json( *args )
      {
        'sha1' => sha1,
        'when' => time,
        'server_port' => server_port,
        'request' => {
          'remote_ip' => request.remote_ip,
          'protocol' => request.protocol,
          'host' => request.host,
          'port' => request.port,
          'domain' => request.domain,
          'format' => request.format,
          'method' => request.method,
          'url' => request.url,
          'query_string' => request.query_string,
        },
        'headers' => extract_headers( request.headers ),
        'session' => request.session,
        'parameters' => request.parameters,
        'error' => {
          'message' => error.message,
          'back_trace' => error.backtrace
        },
        'env' => request.env.slice( *VALID_ENV )
      }.to_json
    end
    
  end
  
end
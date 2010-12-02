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
    
    attr_reader :port
    attr_reader :error
    attr_reader :request_method
    attr_reader :parameters
    attr_reader :time
    attr_reader :env
    attr_reader :sha1
    
    def initialize( error, request )
      @error = error
      @time = Time.now
      @port = Integer( request.env["SERVER_PORT"] )
      @env = request.env
      @request_method = request.request_method
      @parameters = request.parameters
      @sha1 = Digest::SHA1.hexdigest( "#{@port}-#{@time}-#{@error.message}-#{@parameters.inspect}")
    end
    
    def to_json( *args )
      {
        'sha1' => sha1,
        'time' => time,
        'port' => port,
        'request_method' => request_method,
        'parameters' => parameters,
        'error' => {
          'message' => error.message,
          'back_trace' => error.backtrace
        },
        'env' => env.slice( *VALID_ENV )
      }.to_json
    end
    
  end
  
end
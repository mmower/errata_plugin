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
    
    PLUGIN_PATH = File.join( RAILS_ROOT, "vendor", "plugins" )
    RAILS_PATH = File.join( RAILS_ROOT, "vendor", "rails" )
    LIB_PATHS = $LOAD_PATH.reject { |path| path == "." }
    
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
    
    def process_backtrace( backtrace )
      backtrace.collect do |line|
        file_name, line_num, meth_name = line.split( ':' )
        
        meth_name = if meth_name
          meth_name.sub( /in `(.*)'/, '\1' )
        else
          ""
        end
        
        file_path, file_name = if file_name =~ /^#{RAILS_PATH}/
          [RAILS_PATH, File.join( "[RAILS]", file_name.sub( /^#{RAILS_PATH}/, '' ))]
        elsif file_name =~ /^#{PLUGIN_PATH}/
          [PLUGIN_PATH, File.join( "[PLUGINS]", file_name.sub( /^#{PLUGIN_PATH}/, '' ))]
        elsif file_name =~ /^#{RAILS_ROOT}/
          [RAILS_ROOT, File.join( "[PROJ]", file_name.sub( /^#{RAILS_ROOT}/, '' ))]
        elsif ( gem_path = Gem.path.find { |path| file_name =~ /^#{path}/ } )
          [gem_path, File.join( "[GEM]", file_name.sub( /#{gem_path}/, '' ))]
        elsif ( lib_path = LIB_PATHS.find { |path| file_name =~ /^#{path}/ } )
          [lib_path, File.join( "[LIB]", file_name.sub( /#{lib_path}/, '' ))]
        else
          ["", file_name]
        end
        
        {
          'path' => file_path,
          'file' => file_name,
          'line' => line_num,
          'method' => meth_name
        }
      end
    end
    
    def to_json( *args )
      {
        'sha1' => sha1,
        'when' => time.iso8601,
        'server_port' => server_port,
        'request' => {
          'remote_ip' => request.remote_ip,
          'protocol' => request.protocol.sub( /:\/\/$/, '' ),
          'host' => request.host,
          'port' => request.port,
          'domain' => request.domain,
          'format' => request.format['string'],
          'method' => request.method.to_s.upcase,
          'url' => request.url,
          'query_string' => request.query_string,
        },
        'headers' => extract_headers( request.headers ),
        'session' => request.session,
        'parameters' => request.parameters,
        'error' => {
          'class' => error.class.name,
          'message' => error.message,
          'back_trace' => process_backtrace( error.backtrace )
        },
        'env' => request.env.slice( *VALID_ENV )
      }.to_json
    end
    
  end
  
end
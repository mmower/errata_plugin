require 'fileutils'
require 'json'

module Errata
  
  class Logger
    @@registered = false
    
    def self.errata_dir
      dir = File.join( RAILS_ROOT, 'public', 'errata' )
      FileUtils.mkdir_p( dir ) unless File.exists?( dir )
      dir
    end
    
    def self.log( error, request )
      write( Erratum.new( error, request ) )
    end
    
    def self.read_json( file, default )
      if File.exists?( file )
        File.open( file, "r" ) do |file|
          json = file.read
          if json.length > 0
            JSON.parse( json )
          else
            default
          end
        end
      else
        default
      end
    end
    
    def self.write_json( file, lock, data )
      File.open( file, 'w' ) do |file|
        file.flock( File::LOCK_EX ) if lock
        file.write( data.to_json )
        file.flock( File::LOCK_UN ) if lock
      end
    end
    
    def self.process_json( file, lock, default, &blk )
      write_json( file, lock, yield( read_json( file, default ) ) )
    end
    
    def self.cleanup( json )
      if json.length < KEEP_ERRORS
        json
      else
        while json.length >= KEEP_ERRORS
          sha1 = json.shift
          begin
            File.unlink( File.join( errata_dir, "#{sha1}.json" ) )
          rescue => err
            RAILS_DEFAULT_LOGGER.error( "errata: unable to clean up #{File.join( errata_dir, "#{sha1}.json" )}: #{err.message}")
          end
        end
        json
      end
    end
    
    def self.write( capture )
      write_json( File.join( errata_dir, "#{capture.sha1}.json" ), false, capture )
      process_json( File.join( errata_dir, "index.json" ), true, [] ) do |json|
        # json = cleanup( json )
        json.push( capture.sha1 )
      end
    end
    
  end
  
end

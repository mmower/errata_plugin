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
    
    def self.errata_path( path )
      File.join( errata_dir, path )
    end
    
    def self.log( error, request )
      erratum = Erratum.new( error, request )
      write_erratum( erratum )
      update_index( erratum.sha1 )
    end
    
    def self.cleanup( json )
      if json.length < KEEP_ERRORS
        json
      else
        while json.length >= KEEP_ERRORS
          sha1 = json.shift
          begin
            File.unlink( errata_path( "#{sha1}.json" ) )
          rescue => err
            RAILS_DEFAULT_LOGGER.error( "errata: unable to clean up #{File.join( errata_dir, "#{sha1}.json" )}: #{err.message}")
          end
        end
        json
      end
    end
    
    def self.write_erratum( erratum )
      File.open( errata_path( "#{erratum.sha1}.json" ), "w" ) do |file|
        file.write( erratum.to_json )
      end
    end
    
    def self.append( json, sha1 )
      data = if json.length > 0
        begin
          JSON.parse( json )
        rescue => error
          # The index file has been corrupted, this is not
          # a very ideal situation to find ourselves in.
          puts "Parsing error: #{error.message}"
          []
        end
      else
        []
      end
      data.push( sha1 )
      data.to_json
    end
    
    def self.update_index( sha1 )
      File.open( errata_path( 'index.json' ), 'a+') do |file|
        file.flock( File::LOCK_EX )
        file.pos = 0
        data = append( file.read, sha1 )
        file.truncate( 0 )
        file.write data
        file.flock( File::LOCK_UN )
      end
    end
    
  end
  
end

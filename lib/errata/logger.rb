require 'fileutils'
require 'json'

module Errata
  
  class Logger
    
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
      while json.length >= KEEP_ERRORS
        sha1 = json.shift
        begin
          File.unlink( errata_path( "#{sha1}.json" ) )
        rescue => err
          RAILS_DEFAULT_LOGGER.error( "errata: unable to clean up #{errata_path( "#{sha1}.json" )}: #{err.message}")
        end
      end
      json
    end
    
    def self.write_erratum( erratum )
      File.open( errata_path( "#{erratum.sha1}.json" ), "w" ) do |file|
        file.write( erratum.to_json )
      end
    end
    
    def self.append_hash( json, sha1 )
      data = if json.length > 0
        begin
          cleanup( JSON.parse( json ) )
        rescue => error
          # The index file has been corrupted, this is not
          # a very ideal situation to find ourselves in.
          RAILS_DEFAULT_LOGGER.error( "errata: index.json did not parse!" )
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
        data = append_hash( file.read, sha1 )
        file.truncate( 0 )
        file.write data
        file.flock( File::LOCK_UN )
      end
    end
    
  end
  
end

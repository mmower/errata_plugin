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
    
    def self.log_or_ignore( error, request )
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
    
    def self.write_json( file, data )
      File.open( file, "w" ) do |file|
        file.write( data.to_json )
      end
    end
    
    def self.process_json( file, default, &blk )
      write_json( file, yield( read_json( file, default ) ) )
    end
    
    def self.register( capture )
      process_json( File.join( errata_dir, "errata_idx.json" ), [] ) do |json|
        json.push( capture.port ).uniq
      end
      @@registered = true
    end
    
    def self.write( capture )
      register( capture ) unless @@registered
      process_json( File.join( errata_dir, "errata_#{capture.port}.json" ), [] ) do |json|
        json.push( capture )
      end
    end
    
  end
  
end

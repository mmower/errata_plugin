require 'fileutils'
require 'json'

module Errata
  
  class Logger
    
    def self.log_or_ignore( error, request )
      # unless Rails.env.development? || Rails.env.test?
        write( Capture.new( error, request ) )
      # end
    end
    
    def self.write( capture )
      errata_dir = File.join( RAILS_ROOT, 'public', 'errata' )
      FileUtils.mkdir_p( errata_dir ) unless File.exists?( errata_dir )
      
      errata_file = File.join( errata_dir, "errata_#{capture.port}.json" )
      
      errata = if File.exists?( errata_file )
        File.open( errata_file, "r" ) do |file|
          json_source = file.read
          if json_source.length > 0
            JSON.parse( json_source )
          else
            []
          end
        end
      else
        []
      end
      
      errata << capture
      
      File.open( errata_file, "w" ) do |file|
        file.write( errata.to_json )
      end
    end
    
  end
  
end

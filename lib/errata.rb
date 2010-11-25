require 'errata/catcher'
require 'errata/capture'
require 'errata/logger'

module Errata
  VERSION = "1.00"
  
  def self.initialize
    if defined?( ActionController::Base )
      ActionController::Base.__send__( :include, Errata::Catcher )
    end
  end
  
end

Errata.initialize

require 'errata/version'
require 'errata/erratum'
require 'errata/catcher'
require 'errata/logger'

module Errata
  
  KEEP_ERRORS = 100
  
  def self.enabled?
    true
  end
  
  # def self.enabled?
  #   !(Rails.env.development? || Rails.env.test?)
  # end
  
  def self.initialize
    if enabled? && defined?( ActionController::Base )
      RAILS_DEFAULT_LOGGER.info( "Errata/#{VERSION} reporting for duty sir!" )
      ActionController::Base.__send__( :include, Errata::Catcher )
    end
  end
  
end

Errata.initialize

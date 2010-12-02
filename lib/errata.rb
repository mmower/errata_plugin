require 'errata/erratum'
require 'errata/catcher'
require 'errata/logger'

module Errata
  VERSION = "1.00"
  
  def self.enabled?
    true
  end
  
  # def self.enabled?
  #   !(Rails.env.development? || Rails.env.test?)
  # end
  
  def self.initialize
    if enabled? && defined?( ActionController::Base )
      ActionController::Base.__send__( :include, Errata::Catcher )
    end
  end
  
end

Errata.initialize

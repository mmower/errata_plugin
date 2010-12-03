module Errata
  
  module Catcher
    
    def self.included( base )
      base.__send__( :alias_method, :rescue_action_in_public_without_errata, :rescue_action_in_public )
      base.__send__( :alias_method, :rescue_action_in_public, :rescue_action_in_public_with_errata )
    end
    
    def rescue_action_in_public_with_errata( error )
      Errata::Logger.log( error, request )
      rescue_action_in_public_without_errata( error )
    end
    
  end
  
end

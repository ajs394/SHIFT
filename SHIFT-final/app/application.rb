require 'rho/rhoapplication'

class AppApplication < Rho::RhoApplication
  def initialize
    @@toolbar = [
          {:action => :back,    
            :icon => '/public/images/back_btn.png'},
          {:action => :forward, 
            :icon => '/public/images/forward_btn.png'},         
          {:action => :separator},
          {:action => :home},
          #{:action => :refresh},
          {:action => :options,
            :icon => '/public/images/HelpIconWhite.png'}
        ]
        # Important to call super _after_ you define @@toolbar!
        super       
  end
end

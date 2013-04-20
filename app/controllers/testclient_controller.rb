class TestclientController < ApplicationController
    
    #before_filter :authenticate_user!
    before_filter :after_token_authentication

    def client
    end

end

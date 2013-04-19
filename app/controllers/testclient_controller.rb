class TestclientController < ApplicationController
    #before_filter :authenticate_user!
    before_filter :after_token_authentication
    def client
    	#puts "fuck you" * 500
    	if !params[:auth_key].blank?
    		puts "shit"
    		@user = User.find_by_authentication_token(params[:auth_key]) 
    		if user
    			#puts "fuck you"
    			sign_in(:user, @user)
    			redirect_to new_user_session_path
    		end
    	end
    end
end

class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :after_token_authentication
  # #before_filter :skip_trackable

  # # def skip_trackable
  # # 	request.env['devise.skip_trackable'] = true
  # # end

    def after_token_authentication
      #puts "fuck you" * 500
      auth_token = params[:auth_token]
      puts auth_token * 500
      if params[:auth_key].present?
        #puts "shit" * 500
        @user = User.find_by_authentication_token(params[:auth_token]) 
        if user
          #puts "fuck you"
          sign_in(:user, @user)
          redirect_to new_user_session_path
        end
      end
    end

end

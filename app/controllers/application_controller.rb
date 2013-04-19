class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :after_token_authentication
  #before_filter :skip_trackable

  # # def skip_trackable
  # # 	request.env['devise.skip_trackable'] = true
  # # end

  def after_token_authentication
  	if params[:auth_key].present?
  		@user = User.find_by_authentication_token(params[:auth_key]) 
  		if @user
  			sign_in @user
  			#redirect_to root_path
  		end
  	end
  end

end

class ApplicationController < ActionController::Base
  protect_from_forgery

  # before_filter :after_token_authentication
  before_filter :get_request_id

  def get_request_id
    session[:request_id] ||= 0
    session[:request_id] += 1
    @request_id = session[:request_id]
  end

  def after_token_authentication
    auth_token = params[:auth_token]
    if params[:auth_token].present?
      @user = User.find_by_authentication_token(params[:auth_token]) 
      if @user
        sign_in(:user, @user)
        # sign_in_and_redirect(:user, @user, request.referrer)
        # redirect_to new_user_session_path
      else
        authenticate_user!
      end
    else
      authenticate_user!
    end
  end

end

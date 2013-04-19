class MainController < ApplicationController
	
	before_filter :after_token_authentication
	
	def index
	end

end

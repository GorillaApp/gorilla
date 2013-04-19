
require "spec_helper"

describe "authentication token" do

  describe "token" do
  	it "should not be nil on account creation" do
  		user = FactoryGirl.create(:user)
  		user.authentication_token.should_not be_nil
  	end
  end

  describe "logging in with token" do
  	it "should not work if token not provided" do
  		user = FactoryGirl.create(:user)
  		auth_token = user.authentication_token
  		url = "/?auth_token="
  		visit url
  		page.should have_content("You need to sign in or sign up before continuing.")
  	end

  	it "should not work if token is not correct" do
  		user = FactoryGirl.create(:user)
  		auth_token = user.authentication_token
  		url = "/?auth_token=incorrectToken"
  		visit url
  		page.should have_content("Invalid authentication token.")
  	end

  	it "should work if token is provided and is correct" do
  		user = FactoryGirl.create(:user)
  		auth_token = user.authentication_token
  		url = "/?auth_token=" + auth_token
  		visit url
  		page.should have_content("You are already signed in.")
  	end
  end

end



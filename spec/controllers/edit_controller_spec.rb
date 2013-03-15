require 'spec_helper'

describe EditController do

  describe "GET 'load'" do
    it "returns http success" do
      get 'load'
      response.should be_success
    end
  end

  describe "POST 'autosave'" do
    it "returns http success" do
      post 'autosave'
      response.should be_success
    end
  end

end

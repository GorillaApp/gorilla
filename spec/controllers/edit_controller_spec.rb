require 'spec_helper'

describe EditController do

  describe "GET 'load'" do
    it "returns http success" do
      get 'load'
      response.should be_success
    end
  end

  describe "GET 'autosave'" do
    it "returns http success" do
      get 'autosave'
      response.should be_success
    end
  end

end

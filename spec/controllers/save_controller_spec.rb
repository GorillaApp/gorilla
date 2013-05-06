require 'spec_helper'

describe SaveController do

  describe "GET 'file'" do
    it "returns http success" do
      get 'file'
      response.should be_success
    end
  end

end

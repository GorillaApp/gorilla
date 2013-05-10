require 'spec_helper'

describe SaveController do

  describe "POST 'file'" do
    it "returns http success" do
      post 'file'
      response.should be_success
    end
  end

end

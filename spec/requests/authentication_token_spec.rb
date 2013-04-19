
require "spec_helper"

describe "authentication token" do

  describe "token" do
    it "should be nil on account creation" do
      user = FactoryGirl.create(:user)
      user.authentication_token.should_not be_nil
    end
  end

end



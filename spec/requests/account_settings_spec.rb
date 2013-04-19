require "spec_helper"

describe "account settings" do

  describe "account settings link" do
    it "should not be visible if not signed in" do
      visit "/"
      page.should_not have_content("My Account")
    end

    it "should be visible if user signed in" do
      user = FactoryGirl.create(:user)
      visit "/"
      fill_in "Email",            :with => user.email
      fill_in "user_password",    :with => "password"

      click_button "Sign in"
      page.should have_content("My Account")
    end
  end

  # describe "delete account" do
  #   it "should delete the users account", :js => true do
  #     user = FactoryGirl.create(:user)
  #     visit "/"
  #     fill_in "Email",            :with => user.email
  #     fill_in "user_password",    :with => "password"

  #     click_button "Sign in"
  #     visit "/edit/load"
  #     click_link "My Account"
  #     click_button "Cancel my account"
  #     page.driver.browser.switch_to.alert.accept
  #     #click_button "OK"
  #     #page.evaluate_script('window.confirm = function() { return true; }')
  #     User.find_by_email(user.email).should be_nil
  #   end
  # end

end




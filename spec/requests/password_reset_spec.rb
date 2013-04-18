require "spec_helper"

describe "password reset" do

    describe "reset_password_token for users" do

        it "should be nil on new user creation" do
          user = FactoryGirl.create(:user)
          user.reset_password_token.should be_nil
        end

        it "should not be nil on sending of password reset instructions" do
          user = FactoryGirl.create(:user)
          user.send_reset_password_instructions
          user.reset_password_token.should_not be_nil
        end

        it "should be nil after password reset" do
          user = FactoryGirl.create(:user)
          user.send_reset_password_instructions
          user.reset_password!("new password", "new password")
          user.reload
          user.reset_password_token.should be_nil
        end

    end

    describe "reset_password!() method" do

      it "should return false if passwords do not match" do
        user = FactoryGirl.create(:user)
        user.reset_password!("these", "dont match").should eql(false)
      end

      it "should return true if passwords match and successfully changes password" do
        user = FactoryGirl.create(:user)
        user.reset_password!("new password", "new password").should eql(true)

        visit "/users/sign_in"
        fill_in "Email",            :with => user.email
        fill_in "user_password",    :with => "new password"

        click_button "Sign in"

        page.should have_content("Signed in successfully.")
      end

    end

    describe "'Forgot your password?' link" do

      it "should redirect you to the view for reset password" do
        visit "/users/sign_in"
        click_link "Forgot your password?"

        page.should have_content("Forgot your password?")
      end

    end

    describe "'Forgot your password?' form" do

      it "should provide error if no email is provided" do
        visit "/users/password/new"
        click_button "Reset my password"

        page.should have_content("Email can't be blank")
      end

      it "should provide error if user does not exist" do
        visit "/users/password/new"
        fill_in "Email",            :with => "user@doesnotexist.com"
        click_button "Reset my password"

        page.should have_content("Email not found")
      end

      it "should redirect to sign in page if user exists" do
        user = FactoryGirl.create(:user)
        visit "/users/password/new"
        fill_in "Email",            :with => user.email
        click_button "Reset my password"

        page.should have_content("You will receive an email with instructions about how to reset your password in a few minutes.")
      end

    end

    describe "password reset form" do

      it "should exist and be unique to the user" do
        user = FactoryGirl.create(:user)
        user.send_reset_password_instructions
        token = user.reset_password_token
        url = "/users/password/edit?reset_password_token=" + token

        visit url

        page.should have_content("Change your password")
      end

      it "should allow user to successfully reset their password" do
        user = FactoryGirl.create(:user)
        user.send_reset_password_instructions
        token = user.reset_password_token
        url = "/users/password/edit?reset_password_token=" + token

        visit url
        fill_in "New password",            :with => "123456789"
        fill_in "Confirm new password",    :with => "123456789"

        click_button "Change my password"

        page.should have_content("Your password was changed successfully. You are now signed in.")
      end

      it "user should be able to reset password, log out, and log in with new password" do
        user = FactoryGirl.create(:user)
        user.send_reset_password_instructions
        token = user.reset_password_token
        url = "/users/password/edit?reset_password_token=" + token

        visit url
        fill_in "New password",            :with => "123456789"
        fill_in "Confirm new password",    :with => "123456789"

        click_button "Change my password"
        click_link "Sign out"

        visit "/users/sign_in"
        fill_in "Email",            :with => user.email
        fill_in "user_password",    :with => "123456789"
        click_button "Sign in"

        page.should have_content("Signed in successfully.")
      end

    end

end



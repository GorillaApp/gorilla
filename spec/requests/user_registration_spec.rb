
require "spec_helper"

describe "user registration" do
  it "allows new users to register with an email address and password" do
    visit "/users/sign_up"

    fill_in "Email",                 :with => "jzhang621@gmail.com"
    fill_in "user_password",         :with => "password"
    fill_in "Password confirmation", :with => "password"

    click_button "Sign up"

    page.should have_content("Welcome! You have signed up successfully.")
  end
end

describe "user sign in" do
    it "allows an exisiting user to register with their email address and password" do

        visit "/users/sign_in"

        user = User.create(:email    => "jzhang621@gmail.com",
                       :password => "password")

        fill_in "Email",            :with => "jzhang621@gmail.com"
        fill_in "user_password",    :with => "password"

        click_button "Sign in"

        page.should have_content("Signed in successfully.")
  end
end

describe "invalid user sign in" do

  it "checks to see that attempting to login with invalid credentials will not work" do

    visit "/users/sign_in"

    user = User.create(:email => "jzhang621@gmail.com",
                  :password => "password1")

    fill_in "Email",          :with => "jzhang621@gmail.com"
    fill_in "user_password",  :with => "password"

    click_button "Sign in"

    page.should have_content("Invalid email or password.")

  end

end

describe "access testclient/client without authentication" do

  it "checks to see that users get redirected to the sign in page when they attempt to access the testclient without authentication" do

    visit "/"

    page.should have_content("You need to sign in or sign up before continuing.")
  end
end

describe "tests sign out" do

  it "checks to see that users get directed to the correct sign in page" do

    visit "/users/sign_in"

    user = User.create(:email => "jzhang621@gmail.com",
                          :password => "password")

   fill_in "Email",          :with => "jzhang621@gmail.com"
   fill_in "user_password",  :with => "password"

   click_button "Sign in"
   click_link "Sign out"

   page.should have_content("You need to sign in or sign up before continuing.")
  end
end



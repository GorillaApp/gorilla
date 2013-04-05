require 'spec_helper'

describe 'GorillaEditor', :js => true do
  include Capybara::DSL
  
  describe 'logged in user' do
    before (:each) do
      visit '/'

      find("#users_form").click_link "Sign up"

      fill_in :user_email, with: "test@test.com"
      fill_in :user_password, with: "password"
      fill_in :user_password_confirmation, with: "password"

      click_button "Sign up"

      page.should have_content "Signed in as: test@test.com"
      page.should have_content "Welcome!"
    end

    it 'should load a simple file' do
      visit '/testclient/client'

      find('#file').set <<-EOF
LOCUS pGG001 20 bp ds-DNA circular UNK 01-JAN-1980
FEATURES             Location/Qualifiers
     misc_feature    complement(1..10)
                     /ApEinfo_revcolor="#7f7f7f" 
                     /ApEinfo_graphicformat="arrow_data {{0 1 2 0 0 -1} {} 0}" 
                     /ApEinfo_label="ColE1" 
                     /ApEinfo_fwdcolor="#7f7f7f" 
                     /label="ColE1" 
ORIGIN
        1 cgtctctgac cagaccaata
//
  EOF
      click_button "Open File"

      page.should have_content "cgtctctgaccagaccaata"

      find('#ColE1-0-0-main_editor').should have_content "cgtctctgac"
    end
  end
end

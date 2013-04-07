require 'spec_helper'
require 'support/editor_helper'

describe "Load a file", :js => true do
  include Capybara::DSL
  include GorillaHelper
  
  context "while user is logged in" do
    before (:each) do
      visit '/'

      find("#users_form").click_link "Sign up"

      @user = FactoryGirl.attributes_for(:user)
      fill_in :user_email, with: @user[:email]
      fill_in :user_password, with: @user[:password]
      fill_in :user_password_confirmation, with: @user[:password_confirmation]

      click_button "Sign up"

      page.should have_content "Signed in as: #{@user[:email]}"
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

    context 'with a file open' do
      before(:each) do
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

        find('#ColE1-0-0-main_editor').should have_content "cgtctctgac"
      end

      it 'should be able to insert text' do
        set_cursor_at('ColE1-0-0-main_editor', 3)

        type('a')
        
        find('#ColE1-1-0-main_editor').should have_content 'ctctgac'
        find('#ColE1-0-0-main_editor').should have_content 'cgt'
        find(:xpath, "//span[@id='ColE1-0-0-main_editor']/following-sibling::*").should have_content 'a'
      end

      it 'should be able to backspace text' do
        set_cursor_at('ColE1-0-0-main_editor', 5)
        backspace()
        backspace()
        backspace()
        find("#ColE1-0-0-main_editor").should have_content "cgctgac"
      end

      it 'should autosave after editing' do
        set_cursor_at('ColE1-0-0-main_editor', 5)
        type('a')
        type('g')
        find('#main_editor').should have_content "cgtctagctgac"

        page.should have_content "Autosave Successful"
      end
    end
  end
end

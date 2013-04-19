require 'spec_helper'
require 'support/editor_helper'

describe "A user", :js => true do
  include Capybara::DSL
  include GorillaHelper
  
  context "that is logged" do
    before :each do
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

    it 'should be able to load a simple file' do
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

      find('#0-main_editor').should have_content "cgtctctgac"
    end

    context 'and opens a file' do
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

        find('#0-main_editor').should have_content "cgtctctgac"
      end

      it 'should be able to insert text' do
        set_cursor_at('0-main_editor', 3)

        type('a')
        
        find('#1-main_editor').should have_content 'ctctgac'
        find('#0-main_editor').should have_content 'cgt'
        find(:xpath, "//span[@id='0-main_editor']/following-sibling::*").should have_content 'a'
      end

      it 'should be able to insert a, c, t, g, and n' do
        set_cursor_at('0-main_editor', 3)

        type('actgn')
        
        find('#1-main_editor').should have_content 'ctctgac'
        find('#0-main_editor').should have_content 'cgt'

        page.should have_content 'cgtactgnctctgac'
      end

      it 'should not be able to enter any other characters' do
        set_cursor_at('0-main_editor', 5)

        type('abcdefghijklmnopqrstuvwxyz')
        
        page.should have_content 'cgtctacgntctgac'
      end

      it 'should be able to backspace text' do
        set_cursor_at('0-main_editor', 5)
        type(:backspace)
        type(:backspace)
        type(:backspace)
        find("#0-main_editor").should have_content "cgctgac"
      end

      it 'should be able to backspace from text into span' do
        set_cursor_after('0-main_editor', 1)
        type(:backspace)
        type(:backspace)
        find("#0-main_editor").should have_content "cgtctctga"
      end

      it 'should be able to delete text' do
        set_cursor_at('0-main_editor', 2)
        type(:delete)
        type(:delete)
        type(:delete)
        find('#0-main_editor').should have_content "cgctgac"
      end

      it 'should autosave after editing' do
        set_cursor_at('0-main_editor', 5)

        type('ag')

        find('#main_editor').should have_content "cgtctagctgac"

        page.should have_content "Autosave Successful"
      end

      it 'should be able to undo' do
        set_cursor_at('0-main_editor', 0)

        type('t')

        page.should have_content "tcgtctctgaccagaccaata"

        type(:undo)

        page.should have_content "cgtctctgaccagaccaata"
      end

      it 'should be able to redo' do
        set_cursor_at('0-main_editor', 0)

        type('t')

        page.should have_content "tcgtctctgaccagaccaata"

        type(:undo)

        page.should have_content "cgtctctgaccagaccaata"

        type(:redo)

        page.should have_content "tcgtctctgaccagaccaata"
      end

      it 'should be able to delete past the end of a feature' do
        set_cursor_at('0-main_editor', 10)
        type(:delete)
        page.should have_content 'cgtctctgacagaccaata'
      end

      it 'should be able to see the cursor position' do
        click_at('0-main_editor', 3)
        page.should have_content '3 <0>'
        click_at('0-main_editor', 4)
        page.should have_content '4 <1>'
        click_at('0-main_editor', 5)
        page.should have_content '5 <2>'
      end

      it 'should be able to see the selection' do
        select_from('0-main_editor', 0, '0-main_editor', 5)
        simulate_click('0-main_editor')
        page.should have_content 'Start 0 <0>'
        page.should have_content 'End 5 <2>'
        page.should have_content 'Length 5 <2>'
      end
    end

    context 'and opens a slightly more complicated file' do
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
     misc_feature    13..20
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

        find('#0-main_editor').should have_content "cgtctctgac"
      end

      it 'should be able to delete past the end of a feature' do
        set_cursor_at('0-main_editor', 10)
        type(:delete)
        page.should have_content 'cgtctctgacagaccaata'
      end

      it 'should be able to delete over an empty text element' do
        set_cursor_at('0-main_editor', 10)
        type(:delete)
        type(:delete)
        type(:delete)
        page.should have_content 'cgtctctgacaccaata'
      end

      it 'should be able to delete from a text node to a span' do
        set_cursor_after('0-main_editor', 1)
        type(:delete)
        type(:delete)
        page.should have_content 'cgtctctgaccaccaata'
      end
    end
  end
end

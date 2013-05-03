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

        find('#main_editor-0').should have_content "cgtctctgac"
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

        find('#main_editor-0').should have_content "cgtctctgac"
      end

      it 'should be able to insert text' do
        set_cursor_at('main_editor-0', 3)

        type('a')
        
        find('#main_editor-1').should have_content 'ctctgac'
        find('#main_editor-0').should have_content 'cgt'
        find(:xpath, "//span[@id='main_editor-0']/following-sibling::*").should have_content 'a'
      end

      it 'should be able to insert a, c, t, g, and n' do
        set_cursor_at('main_editor-0', 3)

        type('actgn')
        
        find('#main_editor-1').should have_content 'ctctgac'
        find('#main_editor-0').should have_content 'cgt'

        page.should have_content 'cgtactgnctctgac'
      end

      it 'should not be able to enter any other characters' do
        set_cursor_at('main_editor-0', 5)

        type('abcdefghijklmnopqrstuvwxyz')
        
        page.should have_content 'cgtctacgntctgac'
      end

      it 'should be able to backspace text' do
        set_cursor_at('main_editor-0', 5)
        type(:backspace)
        type(:backspace)
        type(:backspace)
        find("#main_editor-0").should have_content "cgctgac"
      end

      it 'should be able to backspace from text into span' do
        set_cursor_after('main_editor-0', 1)
        type(:backspace)
        type(:backspace)
        find("#main_editor-0").should have_content "cgtctctga"
      end

      it 'should be able to delete text' do
        set_cursor_at('main_editor-0', 2)
        type(:delete)
        type(:delete)
        type(:delete)
        find('#main_editor-0').should have_content "cgctgac"
      end

      it 'should autosave after editing' do
        set_cursor_at('main_editor-0', 5)

        type('ag')

        find('#main_editor').should have_content "cgtctagctgac"

        page.should have_content "Autosave Successful"
      end

      it 'should be able to undo' do
        set_cursor_at('main_editor-0', 0)

        type('t')

        page.should have_content "tcgtctctgaccagaccaata"

        type(:undo)

        page.should have_content "cgtctctgaccagaccaata"
      end

      it 'should be able to redo' do
        set_cursor_at('main_editor-0', 0)

        type('t')

        page.should have_content "tcgtctctgaccagaccaata"

        type(:undo)

        page.should have_content "cgtctctgaccagaccaata"

        type(:redo)

        page.should have_content "tcgtctctgaccagaccaata"
      end

      it 'should be able to delete past the end of a feature' do
        set_cursor_at('main_editor-0', 10)
        type(:delete)
        page.should have_content 'cgtctctgacagaccaata'
      end

      it 'should be able to see the cursor position' do
        click_at('main_editor-0', 3)
        page.should have_content '3 <0>'
        click_at('main_editor-0', 4)
        page.should have_content '4 <1>'
        click_at('main_editor-0', 5)
        page.should have_content '5 <2>'
      end

      it 'should be able to see the selection' do
        select_from('main_editor-0', 0, 'main_editor-0', 5)
        simulate_click('main_editor-0')
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

        find('#main_editor-0').should have_content "cgtctctgac"
      end

      it 'should be able to delete past the end of a feature' do
        set_cursor_at('main_editor-0', 10)
        type(:delete)
        page.should have_content 'cgtctctgacagaccaata'
      end

      it 'should be able to delete over an empty text element' do
        set_cursor_at('main_editor-0', 10)
        type(:delete)
        type(:delete)
        type(:delete)
        page.should have_content 'cgtctctgacaccaata'
      end

      it 'should be able to delete from a text node to a span' do
        set_cursor_after('main_editor-0', 1)
        type(:delete)
        type(:delete)
        page.should have_content 'cgtctctgaccaccaata'
      end
    end

    context 'and open a much more complicated file' do
      before(:each) do
        visit '/testclient/client'

        find('#file').set <<-EOF
LOCUS pGG001 20 bp ds-DNA circular UNK 01-JAN-1980
FEATURES             Location/Qualifiers
     misc_feature    complement(join(1..1,3..5,7..7))
                     /ApEinfo_revcolor="#FF0D0D" 
                     /ApEinfo_graphicformat="arrow_data {{0 1 2 0 0 -1} {} 0}" 
                     /ApEinfo_label="ColE1" 
                     /ApEinfo_fwdcolor="#FFFF12" 
                     /label="Joined" 
      misc_feature    9..11
                     /ApEinfo_revcolor="#45FFA8" 
                     /ApEinfo_graphicformat="arrow_data {{0 1 2 0 0 -1} {} 0}" 
                     /ApEinfo_label="ColE1" 
                     /ApEinfo_fwdcolor="#2130FF" 
                     /label="Over1"
      misc_feature    complement(11..18)
                     /ApEinfo_revcolor="#F83BFF" 
                     /ApEinfo_graphicformat="arrow_data {{0 1 2 0 0 -1} {} 0}" 
                     /ApEinfo_label="ColE1" 
                     /ApEinfo_fwdcolor="#FF8921" 
                     /label="Over2"
ORIGIN
        1 cgtctctgac cagaccaata
//
EOF
        click_button "Open File"

        page.should have_content "cgtctctgaccagaccaata"
      end

      #delete
      it 'should be able to select and delete all of a joined feature with backspace' do
        select_from('main_editor-0', 0, 'main_editor-2', 1)
        simulate_click('main_editor-0')
        type(:backspace)
        page.should have_content 'gaccagaccaata'
      end

      it 'should be able to select and delete all of a joined feature with delete' do
        select_from('main_editor-0', 0, 'main_editor-2', 1)
        simulate_click('main_editor-0')
        type(:delete)
        serialize_file()
        page.should have_content "2..4"
        page.should have_content "complement(4..11)"
        page.should have_content "gaccagaccaata"
      end

      it 'should be able to select and delete the first two parts of a joined feature' do
        select_from('main_editor-0', 0, 'main_editor-2', 0)
        simulate_click('main_editor-0')
        type(:delete)
        serialize_file()
        page.should have_content "3..5"
        page.should have_content "complement(1..1)"
        page.should have_content "complement(5..12)"
        page.should have_content "tgaccagaccaata"
      end

      it 'should be able to select and delete a selection in the middle of a joined feature' do
        select_from('main_editor-1', 1, 'main_editor-1', 2)
        simulate_click('main_editor-0')
        type(:delete)
        serialize_file()
        page.should have_content "8..10"
        page.should have_content "complement(join(1..1,3..4,6..6))"
        page.should have_content "complement(10..17)"
        page.should have_content "cgttctgaccagaccaata"
      end

      it 'should be able to select and delete a selection of overlapping features' do
        select_from('main_editor-4', 0, 'main_editor-4', 1)
        simulate_click('main_editor-0')
        type(:delete)
        serialize_file()
        page.should have_content "9..10"
        page.should have_content "complement(join(1..1,3..5,7..7))"
        page.should have_content "complement(11..17)"
        page.should have_content "cgtctctgacagaccaata"
      end
      #copy + paste
      it 'should be able to select and copy and paste all of a joined feature' do
        select_from('main_editor-0', 0, 'main_editor-2', 1)
        simulate_click('main_editor-0')
        type(:copy)
        set_cursor_at('main_editor-5', 5)
        simulate_click('main_editor-5')
        type(:paste)
        serialize_file()
        page.should have_content "complement(join(11..16,24..25)"
        page.should have_content "complement(join(17..17,19..21,23..23))"
        page.should have_content "cgtctctgaccagacccgtctctaata"
      end

      it 'should be able to select and copy and paste the first two parts of a joined feature' do
        select_from('main_editor-0', 0, 'main_editor-2', 0)
        simulate_click('main_editor-0')
        type(:copy)
        set_cursor_at('main_editor-5', 5)
        simulate_click('main_editor-5')
        type(:paste)
        serialize_file()
        page.should have_content "complement(join(11..16,23..24))"
        page.should have_content "complement(join(17..17,19..21))"
        page.should have_content "cgtctctgaccagacccgtctcaata"
      end

      it 'should be able to select and copy and paste a selection in the middle of a joined feature' do
        select_from('main_editor-1', 1, 'main_editor-1', 2)
        simulate_click('main_editor-0')
        type(:copy)
        set_cursor_at('main_editor-5', 5)
        simulate_click('main_editor-5')
        type(:paste)
        serialize_file()
        page.should have_content "complement(join(11..16,18..19))"
        page.should have_content "complement(17..17)"
        page.should have_content "cgtctctgaccagacccaata"
      end

      it 'should be able to select and copy and paste a selection of overlapping features' do
        select_from('main_editor-4', 0, 'main_editor-4', 1)
        simulate_click('main_editor-0')
        type(:copy)
        set_cursor_at('main_editor-5', 5)
        simulate_click('main_editor-5')
        type(:paste)
        serialize_file()
        page.should have_content "complement(join(11..16,18..19))"
        page.should have_content "complement(17..17)"
        page.should have_content "cgtctctgaccagacccaata"
      end
     
      # it 'should be able to select and cut and paste a selection of overlapping features' do
      #   select_from('main_editor-4', 0, 'main_editor-4', 1)
      #   type(:cut)
      #   set_cursor_at('main_editor-4', 5)
      #   simulate_click('main_editor-4')
      #   type(:paste)
      #   serialize_file()
      #   page.should have_content "complement(join(10..15,17..18))"
      #   page.should have_content "complement(16..16)"
      #   page.should have_content "cgtctctgacagacccaata"
      # end

      # it 'should be able to select and cut and paste all of a joined feature' do
      #   select_from('main_editor-0', 0, 'main_editor-2', 1)
      #   type(:cut)
      #   set_cursor_at('main_editor-2', 5)
      #   simulate_click('main_editor-2')
      #   type(:paste)
      #   serialize_file()
      #   page.should have_content "2..4"
      #   page.should have_content "complement(join(4..9,17..18))"
      #   page.should have_content "complement(join(10..10,12..14,16..16))"
      #   page.should have_content "gaccagacccgtctctaata"
      # end
      


    end
  end
end

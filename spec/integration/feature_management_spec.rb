require 'spec_helper'

describe "A user", :js => true do
    include Capybara::DSL

    context "that is logged in" do
        before :each do
            visit '/'

            find_by_id("users_form").click_link "Sign up"

            @user = FactoryGirl.attributes_for(:user)
            fill_in :user_email, with: @user[:email]
            fill_in :user_password, with: @user[:password]
            fill_in :user_password_confirmation, with: @user[:password_confirmation]

            click_button "Sign up"

            page.should have_content "Signed in as: #{@user[:email]}"
            page.should have_content "Welcome!"
        end

        context 'and wants to manage their features' do
            before :each do
                visit '/'

                find_by_id('file').set <<-EOF
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

                find_by_id('main_editor-0').should have_content "cgtctctgac"
            end

            it 'should be able add a new feature' do
                click_link 'Add a feature'

                fill_in :sequence, with: 'gattaca'
                fill_in :name, with: 'movie!'

                click_button "Save Feature"

                page.should have_content "Successfully saved feature"

                click_link 'List of Features'
               
                page.should have_content 'gattaca'
            end

            it 'should be able to delete a feature that it adds' do
                click_link 'Add a feature'

                fill_in :sequence, with: 'gattacaN'
                fill_in :name, with: 'movie 2!'

                click_button "Save Feature"

                page.should have_content "Successfully saved feature"

                click_link 'List of Features'
               
                page.should have_content 'gattacaN'

                t = find("#features-table")
                tr = t.find("tr[data-contents=gattacaN]")
                tr.click_link('X')

                page.should have_content 'Successfully deleted feature'
            end
        end
    end 
end

require 'spec_helper'

describe "edit/load.html.erb" do
  include Capybara::DSL

  it 'should show load on the homepage' , :js => true do
    visit '/'
    
    page.should have_content 'cgtctc'
  end
end

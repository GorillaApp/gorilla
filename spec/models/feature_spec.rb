require 'spec_helper'

describe Features do
  it "tests that creation returns success when user does not exist"  do
    params = {:user_id => 1234, :forward_color => '#f54321', :reverse_color => '#f54321', :name => "erika", :sequence => "aaccg"}
    result = Features.add(params)
    result.should == 1
  end

  it "tests that remove returns success"  do
    params = {:user_id => 1234, :forward_color => '#f54321', :reverse_color => '#f54321', :name => "erika", :sequence => "aaccg"}
    Features.add(params)
    feat = Features.find_by_name("erika")
    result = Features.remove({:id => feat.id})
    result.should == 1
  end

  it "tests that edit always return success" do
    
    params = {:user_id => 12345, :forward_color => '#f54321', :reverse_color => '#f54321', :name => "erika", :sequence => "aaccg"}
    Features.add(params)
    feat = Features.find_by_name("erika")
    params2 = {:id => feat.id, :forward_color => '#f54321', :reverse_color => '#f54321', :name => "erika", :sequence => "aaaaaaaaaaaaaaaaaccg"}
    result = Features.edit(params2)
    result.should == 1
  end

  # it "tests the getAll feature" do
  #   params = {:user_id => 12345, :forward_color => "#f54321", :reverse_color => "#f54321", :name => "erika", :sequence => "aaccg"}

  # end

end

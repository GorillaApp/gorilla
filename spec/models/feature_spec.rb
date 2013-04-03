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

  it "should be able to remove a feature from the database" do
    #depends on the add functionality working correctly
    params = {:user_id => 1234, :forward_color => '#f54321', :reverse_color => '#f54321', :name => "erika", :sequence => "aaccg"}
    Features.add(params)
    feat = Features.find_by_name("erika")
    ID = feat.id
    params2 = {:id => ID}
    Features.remove(params2)
    result = Features.find_by_name("erika")
    result.should == nil
  end

  it "tests that edit always return success" do
    
    params = {:user_id => 12345, :forward_color => '#f54321', :reverse_color => '#f54321', :name => "erika", :sequence => "aaccg"}
    Features.add(params)
    feat = Features.find_by_name("erika")
    params2 = {:id => feat.id, :forward_color => '#f54321', :reverse_color => '#f54321', :name => "erika", :sequence => "aaaaaaaaaaaaaaaaaccg"}
    result = Features.edit(params2)
    result.should == 1
  end

   it "should return all features associated with a user id" do
    params = {:user_id => 12345, :forward_color => "#f54321", :reverse_color => "#f54321", :name => "erika", :sequence => "aaccg"}
    params2 = {:user_id => 12345, :forward_color => '#f54321', :reverse_color => '#f54321', :name => "erika", :sequence => "aaaaaaaaaaaaaaaaaccg"}
    Features.add(params)
    Features.add(params2)
    params3 = {:user_id => 12345}
    puts Features.getAll(params3)
   end

end

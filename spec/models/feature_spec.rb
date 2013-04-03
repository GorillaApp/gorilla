require 'spec_helper'

describe Features do

  it "tests that creation returns success when user does not exist"  do
    params = {:user_id => 1234, :forward_color => 12345, :reverse_color => 54321, :name => "erika", :sequence => "aaccg"}
    result = Features.add(params)
    result.should == 1
  end

  it "tests that creation returns an error when the name already exists"  do
    params = {:user_id => 1234, :forward_color => 12345, :reverse_color => 54321, :name => "erika", :sequence => "aaccgsldfjsdklf"}
    params2 = {:user_id => 12345, :forward_color => 12345, :reverse_color => 54321, :name => "erika", :sequence => "aaccg"}
    Features.add(params)
    result = Features.add(params2)
    result.should == 2
  end

  it "tests that creation returns an error when the sequence already exists"  do
    params = {:user_id => 1234, :forward_color => 12345, :reverse_color => 54321, :name => "erika", :sequence => "aaccg"}
    params2 = {:user_id => 12345, :forward_color => 12345, :reverse_color => 54321, :name => "Delk", :sequence => "aaccg"}
    Features.add(params)
    result = Features.add(params2)
    result.should == 3
  end

  it "tests that remove returns success"  do
    params = {:user_id => 1234, :forward_color => 12345, :reverse_color => 54321, :name => "erika", :sequence => "aaccg"}
    result = Features.add(params)
    result.should == 1
  end

  it "tests that you can remove a feature and then add it" do
    #this test is dependent upon the add method
    params = {:user_id => 1234, :forward_color => 12345, :reverse_color => 54321, :name => "erika", :sequence => "aaccgsldfjsdklf"}
    params2 = {:user_id => 12345, :forward_color => 12345, :reverse_color => 54321, :name => "erika", :sequence => "aaccg"}
    Features.add(params)
    result = Features.add(params2)
    Features.remove(params)
    result2 = Features.add(params2)

    result.should == 2 && result2.should == 1
  end

  it "tests that edit always return success" do
    
    params = {:user_id => 12345, :forward_color => 12345, :reverse_color => 543217, :name => "erika", :sequence => "aaccg"}
    Features.add(params)
    feat = Features.find_by_name("erika")
    params2 = {:id => feat.id, :user_id => 12345, :forward_color => 12345, :reverse_color => 543217, :name => "erika", :sequence => "aaaaaaaaaaaaaaaaaccg"}
    result = Features.edit(params2)
    result.should == 1
  end

  # it "tests the getAll feature" do
  #   params = {:user_id => 12345, :forward_color => 12345, :reverse_color => 54321, :name => "erika", :sequence => "aaccg"}

  # end

end

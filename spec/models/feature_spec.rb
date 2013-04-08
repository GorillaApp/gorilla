require 'spec_helper'

describe Feature do
  it "has a valid factory" do
    FactoryGirl.create(:feature).should be_valid
  end

  it "should be able to be added even when user doesn't exist"  do
    params = FactoryGirl.attributes_for(:feature)
    result = Feature.add(params)
    result.should == 1
  end

  it "should return success when removing features"  do
    params = FactoryGirl.attributes_for(:feature)
    Feature.add(params)
    feat = Feature.find_by_name(params[:name])
    result = Feature.remove({:id => feat.id})
    result.should == 1
  end

  it "should be able to remove a feature from the database" do
    params = FactoryGirl.attributes_for(:feature)
    Feature.add(params)
    feat = Feature.find_by_name(params[:name])
    ID = feat.id
    params2 = {:id => ID}
    Feature.remove(params2)
    result = Feature.find_by_name(params[:name])
    result.should == nil
  end

  it "tests that edit always return success" do
    params = FactoryGirl.attributes_for(:feature)
    Feature.add(params)
    feat = Feature.find_by_name(params[:name])
    params2 = FactoryGirl.attributes_for(:feature2, :name => params[:name])
    params2[:id] = feat.id
    result = Feature.edit(params2)
    result.should == 1
  end

   it "should return all features associated with a user id" do
    params = FactoryGirl.attributes_for(:feature)
    params2 = FactoryGirl.attributes_for(:feature2)
    Feature.add(params)
    Feature.add(params2)
    params3 = {:user_id => 12345}
    puts Feature.getAll(params3)
   end

end

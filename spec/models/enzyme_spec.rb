require 'spec_helper'

describe Enzyme do
  it "has a valid factory" do
    FactoryGirl.create(:enzyme).should be_valid
  end

  it "should be able to be added even when user doesn't exist"  do
    params = FactoryGirl.attributes_for(:enzyme)
    result = Enzyme.add(params)
    result.should == 1
  end

  it "should return success when removing enzymes"  do
    params = FactoryGirl.attributes_for(:enzyme)
    Enzyme.add(params)
    enz = Enzyme.find_by_name(params[:name])
    result = Enzyme.remove({:id => enz.id})
    result.should == 1
  end

  it "should be able to remove a enzyme from the database" do
    params = FactoryGirl.attributes_for(:enzyme)
    Enzyme.add(params)
    enz = Enzyme.find_by_name(params[:name])
    ID = enz.id
    params2 = {:id => ID}
    Enzyme.remove(params2)
    result = Enzyme.find_by_name(params[:name])
    result.should == nil
  end

  it "tests that edit always return success" do
    params = FactoryGirl.attributes_for(:enzyme)
    Enzyme.add(params)
    enz = Enzyme.find_by_name(params[:name])
    params2 = FactoryGirl.attributes_for(:feature2, :name => params[:name])
    params2[:id] = enz.id
    result = Enzyme.edit(params2)
    result.should == 1
  end

  it "should return all enzymes associated with a user id" do
    params = FactoryGirl.attributes_for(:enzyme)
    params2 = FactoryGirl.attributes_for(:enzyme)
    Enzyme.add(params)
    Enzyme.add(params2)
    params3 = {:user_id => 12345}
    puts Enzyme.getAll(params3)
  end

end

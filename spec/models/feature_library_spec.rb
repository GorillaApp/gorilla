require 'spec_helper'

describe FeatureLibrary do

  it "has a valid factory" do
    FactoryGirl.create(:feature_library).should be_valid
  end

  it "return success after adding a library" do
    params = FactoryGirl.attributes_for(:feature_library)
    params2 = FactoryGirl.attributes_for(:feature_library2)
    params3 = FactoryGirl.attributes_for(:feature_library3)
    result = FeatureLibrary.add(params3)
    result.should == 1
  end

  it "should return success when removing feature libraries"  do
    params = FactoryGirl.attributes_for(:feature_library)
    FeatureLibrary.add(params)
    feat = FeatureLibrary.find_by_name(params[:name])
    result = FeatureLibrary.delete_lib({:id => feat.id})
    result.should == 1
  end

  #it "should be able to return all relavant libraries" do
  #
  #end


end

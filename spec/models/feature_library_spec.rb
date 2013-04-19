require 'spec_helper'

describe FeatureLibrary do

  it "has a valid factory" do
    FactoryGirl.create(:feature_library).should be_valid
  end

  it "should return success when removing feature libraries"  do
    params = FactoryGirl.attributes_for(:feature)
    Feature.add(params)


  end

  it "should be able to return all relavant libraries" do

  end


end

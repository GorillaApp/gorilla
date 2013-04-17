class FeatureLibrary < ActiveRecord::Base
  attr_accessible :user_id
  has_many :features

end

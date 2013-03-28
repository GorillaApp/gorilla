class Feature < ActiveRecord::Base
  attr_accessible :forward_color, :name, :reverse_color, :sequence, :user_id
end

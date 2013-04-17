class Enzyme < ActiveRecord::Base
  attr_accessible :comment, :name, :site, :user_id
end

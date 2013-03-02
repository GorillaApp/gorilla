class Autosave < ActiveRecord::Base
  attr_accessible :contents, :name, :save_date, :user_id
end

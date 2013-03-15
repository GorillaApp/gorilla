
# contents -> genbank as a text file 
# name -> key (ID)
# save_date -> current time stamp 
# user -> none for now (iteration 1)


class Autosave < ActiveRecord::Base
  attr_accessible :contents, :name, :save_date, :user_id

  def self.save_file(file_contents, name, save_date, user_id)
  	Autosave.create(contents: file_contents, name: name, save_date: save_date, user_id: user_id)
  end
  
end

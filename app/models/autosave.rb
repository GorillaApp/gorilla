
# contents -> genbank as a text file
# name -> key (ID)
# save_date -> current time stamp
# user -> none for now (iteration 1)

class Autosave < ActiveRecord::Base
  attr_accessible :contents, :name, :user_id

  def self.save_file(file_contents, name, user_id)
    autosaved_file = Autosave.find_by_name_and_user_id(name, user_id)
    if ! autosaved_file.nil?
      autosaved_file.update_attributes(contents: file_contents)
    else
      Autosave.create(contents: file_contents, name: name, user_id: user_id)
    end
  end

  def self.find_autosaved_file(name, user_id)
  	autosaved_file_contents = nil
  	autosaved_file = Autosave.find_by_name_and_user_id(name, user_id)
  	if ! autosaved_file.nil?
  		autosaved_file_contents = autosaved_file.contents
  	end
  	return autosaved_file_contents
  end

  def self.delete_save(name, user_id)
    autosaved_file = Autosave.find_by_name_and_user_id(name, user_id)
    if ! autosaved_file.nil?
      autosaved_file.destroy
    end
  end

end

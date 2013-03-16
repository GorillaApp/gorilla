require 'bio'
require 'open-uri'

class EditController < ApplicationController

  def load

    @file_restore_contents = ''
    file = ''
    file_url = (params[:fileURL].nil? ? "" : params[:fileURL])
    @saveURL = params[:saveURL]

    if not params[:saveURL].blank?
      @saveURL = params[:saveURL]
    end
    
    if not params[:file].blank?
      file = params[:file]
    elsif not params[:fileURL].blank?
      file = open(params[:fileURL]).read()
    end

    @file_contents = file
    @first_line = file.split("\n").first()

    # The view for load grabs the values of file_contents, first_line, and autosaved_file
    @isRestore = false
    @file_restore_contents = Autosave.find_autosaved_file(@first_line)
    if @file_restore_contents != nil
      @isRestore = true
    end

  end



  def autosave
    file = params[:genbank_file]
    id = params[:id]
    time = params[:current_time]
    user = params[:user] #  Current implementation does not include user profiles, all users have id 1


    # save the file in the Autosave database
    Autosave.save_file(file, id, time, user)

    render json: {success: 1}
  end

  def delete
    id = params[:id]
    Autosave.delete_save(id)

    render json: {success: 1} 
  end

end






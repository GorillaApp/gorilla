require 'bio'
require 'open-uri'

class EditController < ApplicationController
  before_filter :authenticate_user!

  def load
    @file_restore_contents = ''
    file = ''
    @saveURL = params[:saveURL]

    if not params[:saveURL].blank?
      @saveURL = params[:saveURL]
    end

    if not params[:file].blank?
      file = params[:file]
    elsif not params[:fileURL].blank?
      # puts "Reading from URL"
      file = open(params[:fileURL]).read()
    end

    @file_contents = file
    @first_line = file.split("\n").first()

    # The view for load grabs the values of file_contents, first_line, and autosaved_file
    @isRestore = false

    p = {:user_id => current_user.id}
    # puts "Test" , p[:user_id]
    features = Feature.getAll({:user_id => current_user.id})
    # puts "Features" , features

    if current_user
      id = current_user.id
      @file_restore_contents = Autosave.find_autosaved_file(@first_line, id)
    end

    if @file_restore_contents != nil
      @isRestore = true
    end

  end

  def autosave
    file = params[:genbank_file]
    id = params[:id]
    user = params[:user]

    # save the file in the Autosave database
    Autosave.save_file(file, id, user)

    render json: {success: 1}
  end

  def delete
    id = params[:id]
    user = params[:user]

    Autosave.delete_save(id, user)

    render json: {success: 1}
  end

end

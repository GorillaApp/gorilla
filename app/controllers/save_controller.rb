class SaveController < ApplicationController
  def file
    file = params[:file]
    render text: file
  end
end

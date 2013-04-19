class FeatureLibraryController < ApplicationController

  def delete_lib
    result = FeatureLibrary.remove(params)
    render :json => {:errCode => result}
  end

  def add

  end

  def getAll
    result = FeatureLibrary.getAll(params)
    render :json => {:feature_libraries => result}
  end


end

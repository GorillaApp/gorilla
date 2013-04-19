class FeatureLibraryController < ApplicationController

  def delete_lib
    result = FeatureLibrary.remove(params)
    render :json => {:errCode => result}
  end

  def add
   result = FeatureLibrary.add(params)
   render :json => {:errCode => result}
  end

  def getAll
    result = FeatureLibrary.getAll(params)
    render :json => {:feature_libraries => result}
  end

  def setSelected
     result = FeatureLibrary.setSelected(params)
     render :json => {:errCode => result}
  end

  def getSelected
    result = FeatureLibrary.getSelected(params)
    render :json => {:selected => result}
  end


end

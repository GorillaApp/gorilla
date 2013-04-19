class EnzymeController < ApplicationController

  SUCCESS = 1
  NAME_EXISTS = 2
  SEQUENCE_EXISTS = 3
  DOES_NOT_EXIST = 4
  UNEXPECTED_EXCEPTION = 5

  def add
    #no matter what happens, the result is returned as an error code
    result = Enzyme.add(params)
    render :json => {:errCode => result}
  end

  def remove
    result = Enzyme.remove(params)
    render :json => {:errCode => result}
  end

  def edit
    result = Enzyme.edit(params)
    render :json => {:errCode => result}
  end

  def getAll
    #returns an array of features
    result = Enzyme.getAll(params)
    render :json => {:enzymes => result}
  end

  def getEnzyme
    result = Enzyme.getFeature(params)
    if result == DOES_NOT_EXIST
      render :json => {:errCode => result}
    else
      render :json => {:enzymes => result}
    end
  end

end

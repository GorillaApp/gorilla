class FeatureController < ApplicationController

  SUCCESS = 1
  NAME_EXISTS = 2
  SEQUENCE_EXISTS = 3
  DOES_NOT_EXIST = 4
  UNEXPECTED_EXCEPTION = 5

	def add
    #no matter what happens, the result is returned as an error code
		result = Features.add(params)
    render :json => {:errCode => result}
	end

	def remove
		result = Features.remove(params)
    render :json => {:errCode => result}
	end

	def edit
    result = Features.edit(params)
    render :json => {:errCode => result}
	end

	def getAll
    #returns an array of features
     result = Features.getAll(params)
     render :json => {:features => result}
	end

	def getFeature
    result = Features.getFeature(params)
    if result == DOES_NOT_EXIST
      render :json => {:errCode => result}
    else
      render :json => {:features => result}
    end
	end

end

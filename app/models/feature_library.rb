class FeatureLibrary < ActiveRecord::Base
  attr_accessible :user_id, :name
  has_many :features
  belongs_to :user

  @@selected_lib = nil

  SUCCESS = 1
  NAME_EXISTS = 2
  SEQUENCE_EXISTS = 3
  DOES_NOT_EXIST = 4
  UNEXPECTED_EXCEPTION = 5

  def self.add(params)
      return SUCCESS
  end

  def self.delete_lib(params)
    @lib = FeatureLibrary.find_by_id(params[:id])
    objs = FeatureLibrary.all(:conditions => ["library_id = ?", (params[:library_id])])
    objs.each do |o|
      o.destroy
    end

    return SUCCESS
  end

  def self.getAll(params)
    allLibs =  FeatureLibrary.all(:conditions => ["_id = ?", (params[:user_id])])
    result = []
    allLibs.each do |feat|
      result.push({:id => feat.id, :name => feat.name})
    end
    return result
  end

end

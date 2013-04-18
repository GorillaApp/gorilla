class FeatureLibrary < ActiveRecord::Base
  attr_accessible :user_id
  has_many :features
  belongs_to :user

  #@@selected_lib = nil
  #
  #SUCCESS = 1
  #NAME_EXISTS = 2
  #SEQUENCE_EXISTS = 3
  #DOES_NOT_EXIST = 4
  #UNEXPECTED_EXCEPTION = 5
  #
  #def self.add(params)
  #    @feature_library = FeatureLibrary.create(params.slice(:user_id, :name, :sequence, :forward_color, :reverse_color))
  #    @feature_library.save!
  #    return SUCCESS
  #end
  #
  #def self.remove(params)
  #  @feature = Feature.find_by_id(params[:id])
  #  if @feature != nil
  #    @feature.destroy
  #    return SUCCESS
  #  end
  #  return DOES_NOT_EXIST
  #end
  #
  #def self.select
  #
  #end

end

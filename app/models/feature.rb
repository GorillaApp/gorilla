class Feature < ActiveRecord::Base
  attr_accessible :forward_color, :name, :reverse_color, :sequence, :user_id

  belongs_to :user

  validates :user_id, :presence => true
  validates :name, :presence => true
  validates :sequence, :presence => true
  validates :forward_color, :presence => true
  validates :reverse_color, :presence => true


  #Validations not working :-(
  #validates_format_of :forward_color, :with => /#\h{6}/, :message => "must be of the form #hhhhhh where h is a hex value"
  #validates_format_of :reverse_color, :with => /#\h{6}/, :message => "must be of the form #hhhhhh where h is a hex value"

  SUCCESS = 1
  NAME_EXISTS = 2
  SEQUENCE_EXISTS = 3
  DOES_NOT_EXIST = 4
  UNEXPECTED_EXCEPTION = 5

  def self.add(params)
   	@feature = Feature.create(params.slice(:user_id, :name, :sequence, :forward_color, :reverse_color))
  	@feature.save!
  	return SUCCESS
  end

  def self.remove(params)
  	@feature = Feature.find_by_id(params[:id])
  	if @feature != nil
  		@feature.destroy
  		return SUCCESS
    end
    return DOES_NOT_EXIST
  end

  def self.edit(params)
    #right now, this method always return success
  	feature = Feature.find_by_id(params[:id])

  	if params[:name] != nil
  		feature.name = params[:name]
  	end
  	if params[:sequence] != nil
  		feature.sequence = params[:sequence]
  	end
  	if params[:forward_color] != nil
  		feature.forward_color = params[:forward_color]
  	end
  	if params[:reverse_color] != nil
  		feature.reverse_color = params[:reverse_color]
  	end

  	feature.save!
  	return SUCCESS
  end

  def self.getAll(params)
    #returns an array of all features that match the user_id
  	allFeat =  Feature.all(:conditions => ["user_id = ?", (params[:user_id])])
    result = []
    allFeat.each do |feat|
      result.push({:id => feat.id, :name => feat.name, :sequence => feat.sequence, :forward_color => feat.forward_color, :reverse_color => feat.reverse_color})
    end
    return result
  end

  def self.getFeature(params)
  	feat = Feature.find_by_user_id_and_id(params[:user_id], params[:id])
    if feat == nil
      return DOES_NOT_EXIST
    else
      return {:id => feat.id, :name => feat.name, :sequence => feat.sequence, :forward_color => feat.forward_color, :reverse_color => feat.reverse_color}
    end

  end
end

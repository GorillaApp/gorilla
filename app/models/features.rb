class Features < ActiveRecord::Base
  attr_accessible :forward_color, :name, :reverse_color, :sequence, :user_id

  SUCCESS = 1
  NAME_EXISTS = 2
  SEQUENCE_EXISTS = 3
  DOES_NOT_EXIST = 4
  I_DONT_EVEN_KNOW_WHATS_GOING_ON_RIGHT_NOW = 5

  def self.add(params)
  	if Features.find_by_name(params[:name]) != nil
  		return NAME_EXISTS
  	elsif Features.find_by_sequence(params[:sequence]) != nil
  		return SEQUENCE_EXISTS
  	end

  	@feature = features.create(params[:user_id],
  							   params[:name],
  							   params[:sequence],
  							   params[:forward_color],
  							   params[:reverse_color])
  	@feature.save
  	return SUCCESS
  end

  def self.remove(params)
  	@feature = Features.find_by_name(params[:name])
  	if @feature != nil
  		@feature.destroy
  		return SUCCESS
  	return I_DONT_EVEN_KNOW_WHATS_GOING_ON_RIGHT_NOW
    end
  end

  def self.edit(params)
    #right now, this method always return success
  	@feature = Features.find_by_name(params[:old_name])
  	if params[:new_name] != nil
  		@feature.name = params[:new_name]
  	end
  	if params[:sequence] != nil
  		@geature.sequence = params[:sequence]
  	end
  	if params[:forward_color] != nil
  		@feature.forward_color = params[:forward_color]
  	end
  	if param[:reverse_color] != nil
  		@feature.reverse_color = params[reverse_color]
  	end

  	@feature.save
  	return SUCCESS
  end

  def self.getAll(params)
    #returns an array of all features that match the user_id
  	allFeat =  Features.all(:conditions => ["user_id = ?", (params[:user_id])])
    return allFeat
  end

  def self.getFeature(params)
  	feat = Features.find_by_user_id_and_name(params[:user_id], params[:name])
    if feat == nil
      return DOES_NOT_EXIST
    else
      return feat
    end

  end

  end


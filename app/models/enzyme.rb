class Enzyme < ActiveRecord::Base
  attr_accessible :comment, :name, :site, :user_id
  belongs_to :user

  SUCCESS = 1
  NAME_EXISTS = 2
  SEQUENCE_EXISTS = 3
  DOES_NOT_EXIST = 4
  UNEXPECTED_EXCEPTION = 5

  def self.add(params)
    @enzyme = Enzyme.create(params.slice(:user_id, :name, :site, :comment))
    @enzyme.save!
    return SUCCESS
  end

  def self.remove(params)
    @enzyme = Enzyme.find_by_id(params[:id])
    if @enzyme != nil
      @enzyme.destroy
      return SUCCESS
    end
    return DOES_NOT_EXIST
  end

  def self.edit(params)
    #right now, this method always return success
    enzyme = Enzyme.find_by_id(params[:id])

    if params[:name] != nil
      enzyme.name = params[:name]
    end
    if params[:site] != nil
      enzyme.site = params[:site]
    end
    if params[:comment] != nil
      enzyme.comment = params[:comment]
    end
    enzyme.save!
    return SUCCESS
  end

  def self.getAll(params)
    #returns an array of all enzymes that match the user_id
    allEnzymes =  Enzyme.all(:conditions => ["user_id = ?", (params[:user_id])])
    result = []
    allEnzymes.each do |enz|
      result.push({:id => enz.id, :name => enz.name, :site => enz.site, :comment => enz.comment})
    end
    return result
  end

  def self.getEnzyme(params)
    enz = Enzyme.find_by_user_id_and_id(params[:user_id], params[:id])
    if enz == nil
      return DOES_NOT_EXIST
    else
      return {:id => enz.id, :name => enz.name, :site => enz.site, :comment => enz.comment}
    end

  end

end

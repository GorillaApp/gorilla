module ApplicationHelper
  def production?
    @is_production ||= (ENV['RAILS_ENV'] == 'production')
  end

  def development?
    not @is_production
  end
end

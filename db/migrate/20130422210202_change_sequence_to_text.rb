class ChangeSequenceToText < ActiveRecord::Migration
  def change
    change_column :features, :sequence, :text
  end
end

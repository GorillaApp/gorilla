class ChangeSequenceToText < ActiveRecord::Migration
  def up
    change_column :features, :sequence, :text
  end

  def down
    Feature.where('LENGTH(sequence) > 255').each do |n|
        n.sequence = n.sequence[0..254]
        n.save!
    end
    change_column :features, :sequence, :string
  end
end

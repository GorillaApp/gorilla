class CreateFeatures < ActiveRecord::Migration
  def change
    create_table :features do |t|
      t.integer :user_id
      t.string :name
      t.string :sequence
      t.string :forward_color
      t.string :reverse_color

      t.timestamps
    end
  end
end

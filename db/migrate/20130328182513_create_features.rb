class CreateFeatures < ActiveRecord::Migration
  def change
    create_table :features do |t|
      t.integer :user_id
      t.string :name
      t.string :sequence
      t.integer :forward_color
      t.integer :reverse_color

      t.timestamps
    end
  end
end

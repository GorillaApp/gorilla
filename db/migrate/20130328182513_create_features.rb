class CreateFeatures < ActiveRecord::Migration
  def change
    create_table :features do |t|
      t.int :user_id
      t.string :name
      t.string :sequence
      t.int :forward_color
      t.int :reverse_color

      t.timestamps
    end
  end
end

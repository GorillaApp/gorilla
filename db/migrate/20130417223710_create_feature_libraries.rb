class CreateFeatureLibraries < ActiveRecord::Migration
  def change
    create_table :feature_libraries do |t|
      t.integer :user_id

      t.timestamps
    end
  end
end

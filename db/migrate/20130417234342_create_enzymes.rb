class CreateEnzymes < ActiveRecord::Migration
  def change
    create_table :enzymes do |t|
      t.string :name
      t.string :site
      t.string :comment
      t.integer :user_id

      t.timestamps
    end
  end
end

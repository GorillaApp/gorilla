class CreateAutosaves < ActiveRecord::Migration
  def change
    create_table :autosaves do |t|
      t.string :name
      t.integer :user_id
      t.text :contents

      t.timestamps
    end
  end
end

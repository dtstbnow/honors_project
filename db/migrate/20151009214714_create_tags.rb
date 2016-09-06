class CreateTags < ActiveRecord::Migration
  def change
    create_table :tags do |t|
      t.string :name
      t.integer :score
      t.timestamps null: false
      t.integer :image_id
    end
  end
end

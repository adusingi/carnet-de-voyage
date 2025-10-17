class CreateMaps < ActiveRecord::Migration[8.0]
  def change
    create_table :maps do |t|
      t.string :title, null: false
      t.text :description
      t.string :destination
      t.integer :privacy, default: 0  # 0: public, 1: private, 2: shared
      t.integer :places_count, default: 0
      t.text :original_text
      t.text :processed_text
      t.references :creator, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end

    add_index :maps, :privacy
    add_index :maps, :created_at
  end
end

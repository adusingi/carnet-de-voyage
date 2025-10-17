class CreatePlaces < ActiveRecord::Migration[8.0]
  def change
    create_table :places do |t|
      t.string :name, null: false
      t.decimal :latitude, precision: 10, scale: 6
      t.decimal :longitude, precision: 10, scale: 6
      t.string :address
      t.string :place_type
      t.string :emoji
      t.text :context
      t.integer :position
      t.references :map, null: false, foreign_key: true

      t.timestamps
    end

    add_index :places, [:map_id, :position]
  end
end

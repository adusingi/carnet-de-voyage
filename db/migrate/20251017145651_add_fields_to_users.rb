class AddFieldsToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :username, :string, null: false
    add_column :users, :role, :integer, default: 0  # 0: free, 1: paid, 2: b2b
    add_column :users, :maps_limit, :integer, default: 5

    add_index :users, :username, unique: true
  end
end

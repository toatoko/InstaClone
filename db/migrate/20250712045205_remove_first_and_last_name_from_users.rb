class RemoveFirstAndLastNameFromUsers < ActiveRecord::Migration[8.0]
  def change
    remove_column :users, :first_name, :string
    remove_column :users, :last_name, :string
  end
end

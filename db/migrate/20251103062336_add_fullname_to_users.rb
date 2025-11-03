class AddFullnameToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :fullname, :string, null: false, default: "default"
  end
end

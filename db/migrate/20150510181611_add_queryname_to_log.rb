class AddQuerynameToLog < ActiveRecord::Migration
  def change
    add_column :logs, :query_name, :string
  end
end

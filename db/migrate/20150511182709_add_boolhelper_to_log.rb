class AddBoolhelperToLog < ActiveRecord::Migration
  def change
    add_column :logs, :helper, :boolean
  end
end

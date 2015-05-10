class RemoveQueryFromLog < ActiveRecord::Migration
  def change
    remove_reference :logs, :query, index: true
    remove_foreign_key :logs, :queries
  end
end

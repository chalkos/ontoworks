class ChangesFieldsInOntologyToNullable < ActiveRecord::Migration
  def change
    change_column :ontologies, :extendable, :boolean, default: false, null: true
    change_column :ontologies, :expires, :datetime, null: true
  end
end

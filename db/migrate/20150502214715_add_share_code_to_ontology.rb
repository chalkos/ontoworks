class AddShareCodeToOntology < ActiveRecord::Migration
  def change
    add_column :ontologies, :share_code, :string
    add_index  :ontologies, :share_code, unique: true
  end
end

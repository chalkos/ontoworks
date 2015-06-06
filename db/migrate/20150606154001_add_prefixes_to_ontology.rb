class AddPrefixesToOntology < ActiveRecord::Migration
  def change
    add_column :ontologies, :prefixes, :text, default: '', null: false
  end
end

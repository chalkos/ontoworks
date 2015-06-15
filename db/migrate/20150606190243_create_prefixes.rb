class CreatePrefixes < ActiveRecord::Migration
  def change
    create_table :prefixes do |t|
      t.references :ontology, index: true
      t.string :name
      t.text :uri
    end
    add_foreign_key :prefixes, :ontologies
  end
end

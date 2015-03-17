class CreateQueries < ActiveRecord::Migration
  def change
    create_table :queries do |t|
      t.string :name, limit: 255, null: false
      t.text :content, limit: 1.megabyte, null: false

      t.belongs_to :ontology, null: false

      t.timestamps null: false
    end
  end
end

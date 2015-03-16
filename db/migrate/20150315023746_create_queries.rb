class CreateQueries < ActiveRecord::Migration
  def change
    create_table :queries do |t|
      t.string :name, limit: 255, null: false
      t.text :content, limit: 1048576, null: false #query maximum size is 1MB

      t.belongs_to :ontology, null: false

      t.timestamps null: false
    end
  end
end

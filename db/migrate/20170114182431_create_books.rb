class CreateBooks < ActiveRecord::Migration[5.0]
  def change
    create_table :books do |t|
      t.text :title
      t.text :author
      t.string :language

      t.timestamps
    end
  end
end

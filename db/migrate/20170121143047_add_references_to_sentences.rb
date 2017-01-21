class AddReferencesToSentences < ActiveRecord::Migration[5.0]
  def change
    add_reference :sentences, :book, foreign_key: true
  end
end

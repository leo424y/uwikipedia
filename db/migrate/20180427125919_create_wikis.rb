class CreateWikis < ActiveRecord::Migration[5.2]
  def change
    create_table :wikis do |t|
      t.string :title
      t.string :lang
      t.integer :count, default: 1
      t.string :u

      t.timestamps
    end
  end
end

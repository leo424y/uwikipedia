class CreateVideos < ActiveRecord::Migration[5.2]
  def change
    create_table :videos do |t|
      t.string :wiki_id
      t.string :yid

      t.timestamps
    end
  end
end

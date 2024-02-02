class CreateMatches < ActiveRecord::Migration[7.1]
  def change
    create_table :matches do |t|
      t.string :title
      t.float :total_amount
      t.string :description
      t.float :base_amount
      t.integer :creator_id

      t.timestamps
    end
  end
end

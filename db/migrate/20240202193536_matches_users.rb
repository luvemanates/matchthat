class MatchesUsers < ActiveRecord::Migration[7.1]
  def up
    create_table :matches_users do |t|
      t.integer :user_id 
      t.integer :match_id
    end
  end

  def down
    drop_table :matches_users
  end
end

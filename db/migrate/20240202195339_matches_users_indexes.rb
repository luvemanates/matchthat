class MatchesUsersIndexes < ActiveRecord::Migration[7.1]
  def up
    add_index :matches, :creator_id

    add_index :matches_users, [ :user_id, :match_id ]
    add_index :matches_users, [ :match_id, :user_id] 

    execute "CREATE FULLTEXT INDEX fulltext_matches ON matches (title, description);"
  end

  def down
    execute "ALTER TABLE tickets DROP INDEX fulltext_matches;"
  end

end

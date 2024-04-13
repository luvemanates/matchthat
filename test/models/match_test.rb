require "test_helper"
require_relative '../../lib/tasks/merkle'

class MatchTest < ActiveSupport::TestCase

  test "the truth" do
     assert true
  end

  test "test merkle tree" do
    mt = MerkleTree.new()
    mt.save

    mt.add_leaf({:stored_data => 'leaf 1'})
    mt.add_leaf({:stored_data => 'leaf 2'})
    assert MerkleTreeNode.where(:node_type => 'LEAF').first.stored_data == "leaf 1"
    assert MerkleTreeNode.where(:node_type => 'LEAF').first.parent.node_type == "ROOT"

    mt.add_leaf({:stored_data => 'leaf 3'})
    mt.add_leaf({:stored_data => 'leaf 4'})
    assert MerkleTreeNode.where(:stored_data => 'leaf 3').first.parent.node_type == "PARENT"

    mt.add_leaf({:stored_data => 'leaf 5'})
    mt.add_leaf({:stored_data => 'leaf 6'})
  end

  test "can create a match with a user" do
    @user = User.new(:email => 'blah@blah.com', :password => 'deftones', :password_confirmation => 'deftones')
    assert_difference("User.count") do
      @user.save
    end
    @user.save
    assert_difference("Match.count") do
      @match = Match.new(:title => "Radio", :total_amount => 0.0, :description => "Radio is worth at least a thousand", :base_amount => 1000.00, :creator_id => @user.id)
      assert @match.save
    end
  end
end

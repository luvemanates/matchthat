require "test_helper"
require_relative '../../lib/tasks/merkle'
require_relative '../../lib/tasks/digital_wallet'
require_relative '../../lib/tasks/mint'

class MatchTest < ActiveSupport::TestCase

  test "the truth" do
     assert true
  end

  test "test ledger with merkle trees" do
    wallet = DigitalWallet.new(:wallet_name => 'test wallet')
    mint = MatchMintingBank.new
    coin = mint.mint(:face_value => 1, :digital_wallet => wallet)
    assert wallet.save
    assert wallet.debit_coin(coin)
    coin = mint.mint(:face_value => 1, :digital_wallet => wallet)
    assert wallet.debit_coin(coin)
    coin = mint.mint(:face_value => 1, :digital_wallet => wallet)
    assert wallet.debit_coin(coin)
    root_node = MerkleTreeNode.where(:id => wallet.ledger.merkle_tree.root_node_id).first
    assert root_node.node_type == 'ROOT'
    assert root_node.children
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
    assert MerkleTreeNode.where(:stored_data => 'leaf 3').first.parent.node_type == "PARENT"

    mt.add_leaf({:stored_data => 'leaf 7'})
    mt.add_leaf({:stored_data => 'leaf 8'})
    assert MerkleTreeNode.where(:stored_data => 'leaf 5').first.parent.node_type == "PARENT"
    assert MerkleTreeNode.where(:stored_data => 'leaf 5').first.parent.parent.node_type == "PARENT"
    assert MerkleTreeNode.where(:stored_data => 'leaf 5').first.parent.parent.parent.node_type == "ROOT"
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

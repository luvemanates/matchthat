xml.instruct! :xml, :version => "1.0"
xml.rss :version => "2.0" do
  xml.channel do
    xml.title "MatchThat Ledger"
    xml.description "Exposing the ledger Bank Wallet of the matchcoin"
    for block in @ledger_entry_blocks
      merkle_hash = block.merkle_tree_node.merkle_hash
      #merkle_root = MerkleTreeNode.where(:id => block.merkle_tree_node.merkle_tree.root_node_id).first
      merkle_root = MerkleTreeNode.where(:id => @ledger.merkle_tree.root_node_id).first
      merkle_root.reload
      xml.item do
        xml.id block.id
        xml.current_hash block.current_hash
        xml.merkle_root merkle_root.merkle_hash
        xml.merkle_hash merkle_hash
        xml.type block.ledger_entry_type
        xml.coin_serial_number block.coin_serial_number
        xml.coin_face_value block.coin_face_value
        xml.entry_amount block.entry_amount
        xml.balance block.balance
        xml.previous_hash block.previous_hash
        xml.updated_at block.updated_at
        xml.created_at block.created_at
      end
    end
  end
end


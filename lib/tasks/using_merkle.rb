require_relative '../../config/environment'
require_relative 'merkle'

mt = MerkleTree.new()
parent_node = mt.add_node(:node_type => 'parent node', :stored_data => 'A parent')
parent_node.save

leaf_node_one = mt.add_node(:node_type => 'leaf', :stored_data => 'Another leaf') #, :parent => parent_node)
leaf_node_one.parent = parent_node
leaf_node_one.save

leaf_node_two = mt.add_node(:node_type => 'leaf', :stored_data => 'Another leaf 2') #, :parent => parent_node)
leaf_node_two.parent = parent_node
leaf_node_two.save


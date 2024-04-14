require_relative '../../config/environment'
require_relative 'merkle'

mt = MerkleTree.new()
mt.save

mt.add_leaf({:stored_data => 'leaf 1'})
mt.add_leaf({:stored_data => 'leaf 2'})
mt.add_leaf({:stored_data => 'leaf 3'})
mt.add_leaf({:stored_data => 'leaf 4'})
mt.add_leaf({:stored_data => 'leaf 5'})
mt.add_leaf({:stored_data => 'leaf 6'})
mt.add_leaf({:stored_data => 'leaf 7'})
mt.add_leaf({:stored_data => 'leaf 8'})
mt.traverse_tree( MerkleTreeNode.where(:merkle_tree_id => mt.id, :node_type => MerkleTreeNode::ROOT).first )
=begin
parent_node = mt.add_node(:node_type => MerkleTreeNode::PARENT, :stored_data => 'A parent')
parent_node.save
puts parent_node.inspect

leaf_node_one = mt.add_node(:node_type => MerkleTreeNode::LEAF, :stored_data => 'leaf node one') #, :parent => parent_node)
leaf_node_one.parent = parent_node
leaf_node_one.save
puts leaf_node_one.inspect

leaf_node_two = mt.add_node(:node_type => MerkleTreeNode::LEAF, :stored_data => 'leaf node two') #, :parent => parent_node)
leaf_node_two.parent = parent_node
leaf_node_two.save
puts "SIBLING FOR LEAF_NODE_TWO" + leaf_node_two.sibling.inspect

puts leaf_node_two.inspect

puts "Leaf height is " + mt.get_leaf_height.to_s

root_node = mt.add_node(:node_type => MerkleTreeNode::ROOT, :stored_data => 'root parent')
root_node.save
puts root_node.inspect
puts "SIBLING FOR ROOT_NODE" + root_node.sibling.inspect

parent_node.parent = root_node
parent_node.save

parent_node3 = mt.add_node(:node_type => MerkleTreeNode::PARENT, :stored_data => 'parent node sibling')
parent_node3.parent = root_node
parent_node3.save
puts "PARENT NODE 3 IS" + parent_node3.inspect

puts "SIBLING FOR PARENT_NODE3" + parent_node3.sibling.inspect

leaf_node_one2 = mt.add_node(:node_type => MerkleTreeNode::LEAF, :stored_data => 'leaf node 3') #, :parent => parent_node)
leaf_node_one2.parent = parent_node3
leaf_node_one2.save
puts leaf_node_one2.inspect

leaf_node_two2 = mt.add_node(:node_type => MerkleTreeNode::LEAF, :stored_data => 'leaf node 4') #, :parent => parent_node)
leaf_node_two2.parent = parent_node3
leaf_node_two2.save

puts leaf_node_two2.inspect

puts "Leaf height is " + mt.get_leaf_height.to_s

puts "HEIGHT 3 " if leaf_node_one2.parent.parent == root_node
puts "TRAVERSING FULL TREE"
mt.traverse_tree( root_node )
=end

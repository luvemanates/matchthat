require 'mongoid'
require 'digest'
require 'base64'

class MerkleTree

  include Mongoid::Document
  include Mongoid::Timestamps

  has_many :merkle_tree_nodes

  attr_accessor :tree
  attr_accessor :root_node

  def initialize(params={})
    super(params)
  end

  def traverse_tree(subtree = nil)
    puts "visiting " + subtree.inspect
    return if subtree.nil?
    #visit current_node
    #puts "current node is " + subtree.inspect
    nsubtree_left  = subtree.children.first
    #puts "nsubtree_left" + subtree.children.first.inspect
    nsubtree_right = subtree.children.last
    #puts "nsubtree_right" + subtree.children.last.inspect
    traverse_tree( nsubtree_left )
    traverse_tree( nsubtree_right )
  end

  def balance_tree(subtree = nil)
    for node in self.merkle_tree_nodes
      if node.node_type == 'leaf'
        balance_tree(node.parent)
      elsif node.node_type == 'node'
        nodes_children = node.children
        if nodes_children.size == 2
          node.merkle_hash = Digest::SHA256.digest( nodes.children.first.merkle_hash + nodes.chilren.last.merkle_hash)
          balance_tree(node.parent)
        elsif nodes_children.size == 1 #hash the same data twice until children size becomes 2
          node.merkle_hash = Digest::SHA256.digest( nodes.children.first.merkle_hash + nodes.chilren.first.merkle_hash)
          balance_tree(node.parent)
        end
      elsif node.node_type == 'root'
        nodes_children = node.children
        if nodes_children.size == 2
          node.merkle_hash = Digest::SHA256.digest( nodes.children.first.merkle_hash + nodes.chilren.last.merkle_hash)
        elsif nodes_children.size == 1
          node.merkle_hash = Digest::SHA256.digest( nodes.children.first.merkle_hash + nodes.chilren.first.merkle_hash)
        else
        end
      end
    end
  end

  def get_leaf_height
    leaf = MerkleTreeNode.where(:node_type => MerkleTreeNode::LEAF).first
    parent = leaf.parent
    leaf_height = 1
    while not parent.nil?
      leaf_height = leaf_height + 1
      parent = parent.parent
    end
    return leaf_height
  end

  def add_leaf(params)
    #recently_added_leaves = MerkleTreeNode.where(:node_type => 'leaf').order(:created_at => :desc).limit(2) 
    new_leaf = MerkleTreeNode.new(:merkle_tree => self, :node_type => MerkleTreeNode::LEAF, :stored_data => params[:data])
    new_leaf.stored_data = params[:stored_data] #there is a bug somehwere because i shouldnt need to do this
    #new_leaf.merkle_hash = Digest::SHA256.digest(new_leaf[:stored_data])
    #new_leaf.fulfilled = true

    #new_leaf.parent = nil
    available_parent = available_parent(new_leaf)
    new_leaf.save
  end

  def available_parent(new_node)
    recently_added_leaf = MerkleTreeNode.where(:merkle_tree => self, :node_type => MerkleTreeNode::LEAF).order(:created_at => :desc).limit(1).first
    if recently_added_leaf.nil?
      #make root
      new_root = MerkleTreeNode.new(:merkle_tree => self, :node_type => MerkleTreeNode::ROOT )
      new_root.save
      new_node.parent = new_root
      new_node.save
      new_root.save
      return new_root
    else #there is a recent leaf that we have
      ral_parent = recently_added_leaf.parent #this shouldn't be nil
      can_add_parent = false
      can_add_parent = (not ral_parent.nil?) 
      can_add_parent_oth = (not ral_parent.children.nil?) if can_add_parent
      if can_add_parent and can_add_parent_oth 
        if recently_added_leaf.parent.children.size == 1
          new_node.parent = recently_added_leaf.parent
          new_node.save
          return recently_added_leaf.parent
        else #recently_added_leaf children is size 2 #last leafs inserted has full parents #need to take care of special cases
          #leaf needs to make  parents based on currentleafheight
          #if root is fulfilled we need to make a new root
          avail_parent_sub(new_node)
        end
      else
        avail_parent_sub(new_node)
      end
    end
  end

  def avail_parent_sub(new_node)
    current_root = MerkleTreeNode.where(:merkle_tree => self, :node_type => MerkleTreeNode::ROOT).first
    if current_root.fulfilled #thinking we should recursively use this code to iterate until an unfulfilled parent
      #make new root
      current_root.node_type = MerkleTreeNode::PARENT
      new_root = MerkleTreeNode.new(:merkle_tree => self, :node_type => MerkleTreeNode::ROOT )
      new_root.save
      current_root.parent = new_root
      current_root.save
      new_root.save #saving twice to compute merkle root with children available

      new_parent = MerkleTreeNode.new(:merkle_tree => self, :node_type => MerkleTreeNode::PARENT )
      new_parent.parent = new_root
      new_parent.save

      previous_parent = new_parent
      leaf_height = get_leaf_height
      i = 2
      while i < leaf_height
        new_parent = MerkleTreeNode.new(:merkle_tree => self, :node_type => MerkleTreeNode::PARENT )
        new_parent.save
        previous_parent.parent = new_parent
        previous_parent.save
        previous_parent = new_parent
        i = i + 1
      end
    else #current_root.fulfilled == false
      avail_parent_sub_rec(current_root, 1, new_node) #, new_node?
    end
    return new_node.parent
  end

  #maybe traverse the tree following unfulfilled nodes, 
  def avail_parent_sub_rec(subtree = nil, current_height = 0, new_node = nil)
    return if subtree == nil
    current_parent = subtree
    leaf_height = get_leaf_height

    parent_children = current_parent.children
    if parent_children.size == 1
      new_parent = MerkleTreeNode.new(:merkle_tree => self, :node_type => MerkleTreeNode::PARENT )
      new_parent.parent = current_parent
      new_parent.save
      avail_parent_sub_rec(new_parent)
    elsif parent_children.size == 0
      if current_height < leaf_height
        new_parent = MerkleTreeNode.new(:merkle_tree => self, :node_type => MerkleTreeNode::PARENT )
        new_parent.parent = current_parent
        new_parent.save
        current_parent.save #save to computer merkle for new child
      else
        new_node.parent = current_parent
        new_node.save
        current_parent.save #save to cacl merkle for new child
      end
    else #size == 2
      if not parent_children.first.fulfilled
        avail_parent_sub_rec(parent_children.first, current_height, new_node)
      end
      if not parent_children.last.fulfilled
        avail_parent_sub_rec(parent_children.last, current_height, new_node)
      end
    end
  end

  #find recent leaves -- if parent is available then add
  #this is the easiest case
  #for the other case we need to add parent nodes -- sometimes replacing the root
  #add parent nodes until leaf height is reached
  def add_node(params)
    new_node = MerkleTreeNode.new(:node_type => params[:node_type], :stored_data => params[:stored_data], :merkle_tree => self)
    return new_node
    #new_node.children
    #check if the number of nodes is even, if not, add a node to the bottom
    #if this node makes the number even, add it, and recursively build hashes.
    #if a node needs to be hashed then we can add it to a hash queue
    #recently_added_leaves = MerkleTreeNode.where(:node_type => 'leaf').order(:created_at => :desc).limit(2) 
    #if the last added leaves are on the same node don't do anything
    #if the last added leafe is on a s
  end


end

class MerkleTreeNode

  include Mongoid::Document
  include Mongoid::Timestamps
  belongs_to :merkle_tree
  #belongs_to :merkle_tree_node

  belongs_to :parent, optional: true, :class_name => 'MerkleTreeNode', :foreign_key => 'parent_id', :index => true
  #has_many :children, :class_name => 'MerkleTreeNode', :primary_key => 'id', :foreign_key => 'parent_id'


  field :node_type
  field :stored_data
  field :merkle_hash
  field :fulfilled

  before_save :do_digest_fulfillment

  LEAF = "LEAF"  #MerkleTreeNode::LEAF 
  PARENT = "PARENT" #MerkleTreeNode::PARENT
  ROOT = "ROOT" #MerkleTreeNode::ROOT

  def initialize(params={})
    super(params)
  end

  def do_digest_fulfillment
    return if self.fulfilled
    case self.node_type
    when MerkleTreeNode::LEAF
      puts "printing in digest fulfillment"
      puts self.inspect
      self.merkle_hash = Base64.encode64(Digest::SHA256.digest(self.stored_data))
      self.fulfilled = true
    when MerkleTreeNode::PARENT, MerkleTreeNode::ROOT
      children = self.children
      if children.size == 2
        dec_fc = Base64.decode64(children.last.merkle_hash) 
        dec_sc = Base64.decode64(children.first.merkle_hash)
        self.merkle_hash = Base64.encode64(Digest::SHA256.digest(dec_fc + " " + dec_sc))
        self.fulfilled = true
      elsif children.size == 1
        unless children.first.merkle_hash.nil?
          dec_fc = Base64.decode64(children.first.merkle_hash) 
          self.merkle_hash = Base64.encode64(Digest::SHA256.digest(dec_fc + " " + dec_fc))
          self.fulfilled = false
        end
      else #parent of no one do nothing
      end
    end
  end

  #right child is most recently made
  #left child is the older of the siblings
  def children
    MerkleTreeNode.all.where(:parent_id => self.id).order(:created_at => :desc)
  end

  def sibling(node = self)
    return if node.nil?
    common_parent = node.parent
    return if common_parent.nil?
    parent_children = common_parent.children
    return if parent_children.nil?
    for n in parent_children
      if n.id != node.id
        return n
      end
    end
  end
end

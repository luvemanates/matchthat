require 'digest'
require 'mongoid'
require 'logger'

class Ledger
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :digital_wallet, :index => true
  has_many :ledger_entry_blocks #object type is LedgerEntryBlock (has_many)

  field :ledger_name
  field :current_ledger_amount #should be all the debit - all the credits

  attr_accessor :logger
  #It would probably be better accounting to have a balance update in the entry
  #field :new_balance
  after_find :init_logger
  before_create :init_logger

  def initialize(params = {:ledger_name => "Default Ledger Name", :current_ledger_amount => 0})
    super(params)
  end

  def init_logger
    @logger = Logger.new(Logger::DEBUG)
  end

  def new_entry(new_ledger_block)
    self.ledger_entry_blocks << new_ledger_block
    update_amount
  end

  def update_amount
    credits = 0
    debits = 0
    for entry_block in self.ledger_entry_blocks
      if entry_block.ledger_entry_type == LedgerEntryBlock::CREDIT
        credits -= entry_block.entry_amount.to_i
      elsif entry_block.ledger_entry_type == LedgerEntryBlock::DEBIT
        debits += entry_block.entry_amount.to_i
      end
    end
    current_ledger_amount = debits - credits
    return current_ledger_amount
  end

  def can_verify_current_ledger_amount?
    credits = 0
    debits = 0
    for entry_block in self.ledger_entry_blocks
      if entry_block.ledger_entry_type == LedgerEntryBlock::CREDIT
        credits -= entry_block.entry_amount
      elsif entry_block.ledger_entry_type == LedgerEntryBlock::DEBIT
        debits += entry_block.entry_amount
      end
    end
    current_tally = debits - credits
    if current_tally == @current_ledger_amount #should be all the debit - all the credits
      return true
    else
      return false
    end
  end
end

class LedgerEntryBlock

  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :ledger, :index => true


#  BALANCE = "balance"

  field :entry_amount
  field :balance
  field :ledger_entry_type #credit or debit
  field :coin_serial_number
  field :coin_face_value
  field :current_hash
  field :previous_hash

  attr_accessor :logger
  #It would probably be better accounting to have a balance update in the entry
  #field :new_balance
  after_find :init_logger
  before_create :init_logger
  before_create :update_balance, :calculate_hash

  CREDIT = "credit"
  DEBIT = "debit"

  def initialize(params)
    @logger = Logger.new(Logger::DEBUG)
    @ledger_entry_type = params[:ledger_entry_type]
    
    @logger.debug( "inspecting params passed to ledger")
    @logger.debug( params.inspect )
    @entry_amount = params[:coin].face_value 
    @coin_serial_number = params[:coin].serial_number
    @coin_face_value = params[:coin].face_value

    params[:entry_amount] = params[:coin].face_value 
    params[:coin_serial_number] = params[:coin].serial_number
    params[:coin_face_value] = params[:coin].face_value
    params.delete(:coin)
    super(params)
  end

  def update_balance
    previous_block = self.ledger.ledger_entry_blocks.order(:created_at => :desc).first
    self.balance = previous_block.balance
    if self.balance == nil 
      self.balance = 0
    end
    self.balance = self.balance.to_i + self.coin_face_value.to_i if self.ledger_entry_type == DEBIT
    self.balance = self.balance.to_i - self.coin_face_value.to_i if self.ledger_entry_type == CREDIT
  end

  def calculate_hash
    previous_block = self.ledger.ledger_entry_blocks.order(:created_at => :desc).first
    if previous_block.nil?
      self.previous_hash = "Genesis Block" 
    else
      self.previous_hash = previous_block.current_hash
    end
    self.current_hash = Digest::SHA256.hexdigest("#{self.id}#{self.created_at}#{self.coin_serial_number}#{self.balance}#{self.ledger_entry_type}#{previous_hash}")
  end

  def init_logger
    @logger = Logger.new(Logger::DEBUG)
  end
end



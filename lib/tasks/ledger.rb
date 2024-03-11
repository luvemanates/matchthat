require 'mongoid'

class Ledger
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :digital_wallet
  has_many :ledger_entry_blocks #object type is LedgerEntryBlock (has_many)

  field :ledger_name
  field :current_ledger_amount #should be all the debit - all the credits

  def initialize(params = {:ledger_name => "Default Ledger Name", :current_ledger_amount => 0})
    super(params)
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
        credits -= entry_block.entry_amount
      elsif entry_block.ledger_entry_type == LedgerEntryBlock::DEBIT
        debits += entry_block.entry_amount
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

  belongs_to :ledger


#  BALANCE = "balance"

  field :entry_amount
  field :ledger_entry_type #credit or debit
  field :coin_serial_number
  field :coin_face_value

  #It would probably be better accounting to have a balance update in the entry
  #field :new_balance

  CREDIT = "credit"
  DEBIT = "debit"

  def initialize(params)
    @ledger_entry_type = params[:ledger_entry_type]
    @entry_amount = params[:coin].face_value 
    @coin_serial_number = params[:coin].serial_number
    @coin_face_value = params[:coin].face_value

    params[:entry_amount] = params[:coin].face_value 
    params[:coin_serial_number] = params[:coin].serial_number
    params[:coin_face_value] = params[:coin].face_value
    params.delete(:coin)
    super(params)
  end
end



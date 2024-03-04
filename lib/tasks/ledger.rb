class Ledger
  attr_accessor :ledger_name
  attr_accessor :ledger_entry_blocks #object type is LedgerEntryBlock (has_many)
  attr_accessor :current_ledger_amount #should be all the debit - all the credits

  def initialize(ledger_name="Default Ledger Name", ledger_entry_blocks=[], current_ledger_amount=0)
    self.ledger_name = ledger_name
    self.ledger_entry_blocks = ledger_entry_blocks
    self.current_ledger_amount = current_ledger_amount
  end

  def new_entry(new_ledger_block)
    self.current_ledger_blocks << new_ledger_block
    update_amount
  end

  def update_amount
    credits = 0
    debits = 0
    for entry_block in self.ledger_entry_blocks
      if entry_block.ledger_entry_type == LedgerEntryBLock::CREDIT
        credits -= entry_block.entry_amount
      elsif entry_block.ledger_entry_type == LedgerEntryBLock::DEBIT
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
      if entry_block.ledger_entry_type == LedgerEntryBLock::CREDIT
        credits -= entry_block.entry_amount
      elsif entry_block.ledger_entry_type == LedgerEntryBLock::DEBIT
        debits += entry_block.entry_amount
      end
    end
    current_tally = debits - credits
    if current_tally == self.current_ledger_amount #should be all the debit - all the credits
      return true
    else
      return false
    end
  end
end

class LedgerEntryBlock

  CREDIT = "credit"
  DEBIT = "debit"

  attr_accessor :entry_amount
  attr_accessor :ledger_entry_type #credit or debit
  attr_accessor :coin_serial_number

  def initialize(ledger_entry_type, coin)
    self.ledger_entry_type = ledger_entry_type
    self.entry_amount = coin.face_value 
    self.coin_serial_number = coin.serial_number
  end
end



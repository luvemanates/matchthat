require 'securerandom'
require_relative 'ledger'

class MatchMintingBank
  attr_accessor :time_elapsed
  attr_accessor :total_coins
  attr_accessor :ledger

  def initialize
    @ledger = Ledger.new('MatchMint Ledger', [], 0)
    @total_coins = 0
    @time_elapsed = 0
  end

  def mint(new_coin_amount)
    @total_coins = @total_coins + new_coin_amount
    (i..new_coin_amount).each do |unit|
      coin = MatchMintCoin.new
      ledger_block_entry = LedgerBlockEntry.new(LedgerBlockEntry::DEBIT, 1, coin)
      ledger.new_entry(ledger_block_entry)
      return coin
    end
  end

end


# A non fungible coin
class MatchMintCoin #or match coin
  attr_accessor :serial_number
  attr_writer :created_at
  attr_writer :face_value

  def initialize(face_value = 1)
    self.serial_number = SecureRandom.uuid 
    self.created_at = Time.now
    self.face_value = face_value
  end
end

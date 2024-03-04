require 'securerandom'
require_relative 'ledger'
require_relative 'centralized_exchange'

class MatchMintingBank
  attr_accessor :time_elapsed
  attr_accessor :total_coins
  attr_accessor :ledger
  attr_accessor :exchange

  def initialize
    @ledger = Ledger.new('MatchMint Ledger', [], 0)
    @total_coins = 0
    @time_elapsed = 0
    @exchange = CentralizedExchange.new
  end

  def mint(coin_face_value)
    while @exchange.is_already_minted_coin?(coin)
      puts 'This coin has already been minted, so it will not be added to the exchange, or added to the ledger.'
      coin = MatchMintCoin.new(coin_face_value)
    end
    @exchange.coins << coin 
    @total_coins = @total_coins + coin_face_value
    ledger_block_entry = LedgerBlockEntry.new(LedgerBlockEntry::DEBIT, coin)
    ledger.new_entry(ledger_block_entry)
    return coin
  end

end


# A non fungible coin
class MatchMintCoin #or match coin
  attr_accessor :serial_number
  attr_writer :created_at
  attr_accessor :face_value

  def initialize(face_value = 1)
    self.serial_number = SecureRandom.uuid 
    self.created_at = Time.now
    self.face_value = face_value
  end
end

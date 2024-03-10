require 'securerandom'
require_relative 'ledger'
require_relative 'centralized_exchange'
require_relative 'matchthat_cryptography'

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
    coin = MatchMintCoin.new(coin_face_value)
    while @exchange.is_already_minted_coin?(coin)
      puts 'This coin has already been minted, so it will not be added to the exchange, or added to the ledger.'
      coin = MatchMintCoin.new(coin_face_value)
    end
    @exchange.coins << coin 
    @total_coins = @total_coins + coin_face_value
    ledger_entry_block = LedgerEntryBlock.new(LedgerEntryBlock::DEBIT, coin)
    @ledger.new_entry(ledger_entry_block)
    return coin
  end

end


# A non fungible coin
# Needs its own private key that is created for any new owners of the coin
class MatchMintCoin #or match coin
  attr_accessor :serial_number
  attr_writer :created_at
  attr_accessor :face_value
  attr_accessor :crypto_card 

  def initialize(face_value = 1)
    @serial_number = SecureRandom.uuid 
    @created_at = Time.now
    @face_value = face_value
    @crypto_card = MatchThatCryptography.new(MatchThatCryptography::CONFIG, "coin card")
  end
end

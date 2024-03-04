require_relative 'mint'

class CentralizedExchange

  #kind of think this should have all wallets
  #e.g. has_many :wallets which has_many :coins

  #this should also keep a record of what is minted, and what isn't

  attr_accessor :coins

  def initialize(coins=[])
    @coins = coins
  end

  def is_already_minted_coin?(coin)
    coins.include?(coin)
  end

  def remove_duplicates_or_forgeries
    serial_numbers = []
    for coin in @coins
      if not serial_numbers.include?(coin.serial_number)
        serial_numbers << coin.serial_number 
      else
        @coins.delete(coin)
      end
    end
    return @coins
  end

  def self.transfer(sender_wallet, receiver_wallet, amount=1)
    tx_coin = sender_wallet.credit_coin
    receiver_wallet.debit_coin(tx_coin)
  end
end

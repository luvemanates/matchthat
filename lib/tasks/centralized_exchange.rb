require_relative 'mint'

class CentralizedExchange

  #kind of think this should have all wallets
  #e.g. has_many :wallets which has_many :coins

  #this should also keep a record of what is minted, and what isn't

  attr_accessor :coins
  attr_accessor :wallets

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

  #this needs an authorization from both wallets
  def self.transfer(sender_wallet, receiver_wallet, amount=1)
    #use the crypto card to ask for auth for a credit on the sender with receiver ident
    #auth = sender_wallet.request_credit_auth_from(receiver_wallet)
    tx_coin = sender_wallet.credit_coin
    receiver_wallet.debit_coin(tx_coin)
  end
end

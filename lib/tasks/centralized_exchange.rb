require_relative 'mint'
require_relative 'digital_wallet'

class CentralizedExchange

  #kind of think this should have all wallets
  #e.g. has_many :wallets which has_many :coins

  #this should also keep a record of what is minted, and what isn't

  #another thing this class should do is verify valid wallets along with valid coins

  #it may actually be good to have multiple exchanges --- but they'll need to be able to connect to each other to verify blockchain like bitcoin
  # the thing about this though is having more than one centralized exchange on one machine doesn't make sense (perhaps would should issue a api key and have
  # tiers like RFID and passports

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
    # This is where the private keys for each coin need to be re-made (like changing the locks after a new owner is moved in.
    sender_wallet.check_balance
    puts "crediting coin from wallet identification: " + sender_wallet.wallet_identification
    tx_coin = sender_wallet.credit_coin
    sender_wallet.check_balance
    puts "debiting coin from wallet identification: " + receiver_wallet.wallet_identification
    receiver_wallet.check_balance
    receiver_wallet.debit_coin(tx_coin)
    receiver_wallet.check_balance
  end
end

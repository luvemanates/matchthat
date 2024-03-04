require 'securerandom'
require_relative 'ledger'
#how do we verify a wallet isn't just creating as many coins as it wants?
#the bank ledger should perhaps own and issue the wallet even if someone else is using it.

class DigitalWallet
  attr_reader :balance
  attr_accessor :crypto_card #crypto card needs to have its own private key, and password
  attr_accessor :wallet_name
  attr_accessor :ledger #each wallet should have its own ledger for credits and debits
  attr_accessor :coins
  attr_reader :wallet_identification

  def initialize(wallet_name, crypto_card, coins=[], ledger=Ledger.new)
    @wallet_name = wallet_name
    @crypto_card = crypto_card
    @coins = coins
    @ledger = ledger
    @balance = ledger.current_ledger_amount
    @wallet_identification = SecureRandom.uuid
  end

  def debit_coin(coin)
    ledger_entry_block = LedgerEntryBlock.new( LedgerEntryBlock::DEBIT,1, coin)
    @ledger.ledger_entry_blocks << ledger_entry_block
    @coins << coin
  end

  def credit_coin
    coin = @coins.last
    ledger_entry_block = LedgerEntryBlock.new( LedgerEntryBlock::CREDIT,1, coin)
    @ledger.ledger_entry_blocks << ledger_entry_block
    return coin
  end

  def check_balance
    puts "The current balance of " + @wallet_name.to_s + " #{@balance}."
  end
end


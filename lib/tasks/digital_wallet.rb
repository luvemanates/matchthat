require 'mongoid'
require 'securerandom'
require_relative 'ledger'
#how do we verify a wallet isn't just creating as many coins as it wants?
#the bank ledger should perhaps own and issue the wallet even if someone else is using it.

class DigitalWallet
  include Mongoid::Document
  include Mongoid::Timestamps

  has_one :crypto_card, :as => :crypto_card_carrier #crypto card needs to have its own private key, and password
  has_one :ledger #each wallet should have its own ledger for credits and debits

  has_many :coins

  field :wallet_name
  field :balance
  field :wallet_identification

  after_create :do_crypto_card, :do_ledger

  def initialize(params={:wallet_name => 'Default Wallet', :balance => 0, :wallet_identification => SecureRandom.uuid})
    super(params)
  end

  def do_ledger
    ledger = Ledger.new(:ledger_name => self.wallet_name + " Ledger")
    ledger.digital_wallet = self
    ledger.save
  end

  def do_crypto_card
    #return if MatchThatCryptography.where(
    @crypto_card = MatchThatCryptography.new
    @crypto_card.crypto_card_carrier = self
    @crypto_card.save
  end

  #need to ensure we are not trying to debit the same coin twice
  def debit_coin(coin)
    ledger_entry_block = LedgerEntryBlock.new( LedgerEntryBlock::DEBIT, coin)
    @ledger.ledger_entry_blocks << ledger_entry_block
    @coins << coin
    @balance += coin.face_value
  end

  #there needs to be something better here if minting face values less or more than 1
  def credit_coin 
    coin = @coins.last
    @coins.delete(coin)
    ledger_entry_block = LedgerEntryBlock.new( LedgerEntryBlock::CREDIT, coin)
    @ledger.ledger_entry_blocks << ledger_entry_block
    @balance -= coin.face_value
    return coin
  end

  def request_credit_auth_from(receiver_wallet)
    return true
    #verify a secret has been shared
  end

  def check_balance
    puts "The current balance of " + @wallet_name.to_s + " #{@balance}."
  end
end


require 'mongoid'
require 'securerandom'
require_relative 'ledger'
require_relative 'mint'
require 'logger'

#how do we verify a wallet isn't just creating as many coins as it wants?
#the bank ledger should perhaps own and issue the wallet even if someone else is using it.

class DigitalWallet
  include Mongoid::Document
  include Mongoid::Timestamps

  has_one :crypto_card, :as => :crypto_card_carrier #crypto card needs to have its own private key, and password
  has_one :ledger #each wallet should have its own ledger for credits and debits

  has_many :coins, :class_name => 'MatchMintCoin'

  field :wallet_name
  field :balance
  field :wallet_identification

  after_create :do_crypto_card, :do_ledger

  # it would be fine to have this
  after_find :init_logger
  before_create :init_logger

  attr_accessor :logger


  def initialize(params={})
    if params[:wallet_name].nil?
      params[:wallet_name] = 'Default Wallet'
    end
    if params[:balance].nil?
      params[:balance] = 0
    end
    if params[:wallet_identification].nil?
      params[:wallet_identification] = SecureRandom.uuid
    end
    super(params)
  end

  def init_logger
    @logger = Logger.new(Logger::DEBUG)
    @logger.debug("initialized logger in digital wallet")
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
    ledger_entry_block = LedgerEntryBlock.new(:ledger_entry_type => LedgerEntryBlock::DEBIT, :coin => coin)
    self.ledger.ledger_entry_blocks << ledger_entry_block
    self.coins << coin;

    @logger.debug("debit coin is ")
    @logger.debug(coin.inspect)

    self.balance += coin.face_value
  end

  #there needs to be something better here if minting face values less or more than 1
  def credit_coin 
    coins = MatchMintCoin.where(:digital_wallet_id => self.id) 
    #self.coins.delete(coin)
    coin = coins.first
    @logger.debug("coin credit is ")
    @logger.debug(coin.inspect)
    ledger_entry_block = LedgerEntryBlock.new({:ledger_entry_type => LedgerEntryBlock::CREDIT, :coin => coin})
    self.ledger.ledger_entry_blocks << ledger_entry_block
    self.balance -= coin.face_value
    return coin
  end

  def request_credit_auth_from(receiver_wallet)
    return true
    #verify a secret has been shared
  end

  def check_balance
    @logger.debug("The current balance of " + self.wallet_name.to_s + " #{self.balance}.")
    return self.balance
  end
end


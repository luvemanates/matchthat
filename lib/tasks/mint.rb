require 'mongoid'
require 'securerandom'
require_relative 'ledger'
require_relative 'centralized_exchange'
require_relative 'matchthat_cryptography'

#I think this class should have a digital wallet

class MatchMintingBank

  attr_accessor :time_elapsed
  attr_accessor :total_coins
  attr_accessor :ledger
  attr_accessor :exchange
  attr_accessor :logger

  def initialize
    @logger = Logger.new(Logger::DEBUG)
    @ledger = Ledger.new(:ledger_name => 'MatchMint Ledger')
    @total_coins = 0
    @time_elapsed = 0
    @exchange = CentralizedExchange.new
  end

  def mint(params = {:face_value => 1, :digital_wallet => digital_wallet})
    coin = MatchMintCoin.new(:face_value => params[:face_value], :digital_wallet => params[:digital_wallet])
    while @exchange.is_already_minted_coin?(coin)
      @logger.warn 'This coin has already been minted, so it will not be added to the exchange, or added to the ledger.'
      coin = MatchMintCoin.new(coin_face_value)
    end
    coin.save
    @ledger = Ledger.new(:ledger_name => 'MatchMint Ledger') if @ledger.nil?
    @exchange.coins << coin 
    @total_coins = @total_coins + params[:face_value]
    ledger_entry_block = LedgerEntryBlock.new(:ledger_entry_type => LedgerEntryBlock::DEBIT, :coin => coin)
    ledger_entry_block.ledger = @ledger
    @ledger.new_entry(ledger_entry_block)
    return coin
  end

end


# A non fungible coin
# Needs its own private key that is created for any new owners of the coin
class MatchMintCoin #or match coin
  include Mongoid::Document
  include Mongoid::Timestamps

  field :serial_number
  index({ serial_number: 1}, { unique: true })
  field :created_at
  field :face_value
  has_one :crypto_card, :as => :crypto_card_carrier, :class_name => 'MatchThatCryptography'
  belongs_to :digital_wallet, :index => true

  #attr_accessor :serial_number
  #attr_writer :created_at
  #attr_accessor :face_value
  attr_accessor :logger
  #attr_accessor :crypto_card 
  after_create :do_crypto_card
  after_find :init_logger
  before_create :init_logger

  def initialize(params = ({face_value: 1, serial_number: SecureRandom.uuid}))
    @logger = Logger.new(Logger::DEBUG)
    @logger.debug "match mint init params is "
    @logger.debug params.inspect
    if params['face_value'].nil?
      params['face_value'] = 1
    end
    if params['serial_number'].nil?
      params['serial_number'] = SecureRandom.uuid
    end
    if params[:digital_wallet].nil?
      throw "No wallet found"
    end
    #crypto_card = MatchThatCryptography.new(:card_name => "coin card")
    #@crypto_card = crypto_card.save 
    #params[:crypto_card] = @crypto_card
    super(params)
  end

  def init_logger
    @logger = Logger.new(Logger::DEBUG)
    @logger.debug("initialized logger in MatchMintCoin")
  end
  
  def do_crypto_card
    crypto_card = MatchThatCryptography.new(:card_name => "coin card")
    crypto_card.crypto_card_carrier = self
    @crypto_card = crypto_card.save 
  end

  def tx_keys
    old_card = self.crypto_card
    new_crypto_card = MatchThatCryptography.new(:card_name => "coin card")
    new_crypto_card.crypto_card_carrier = self
    new_crypto_card.save 
    self.crypto_card = new_crypto_card
    self.save
    old_card.destroy
  end
end

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

  def initialize
    @ledger = Ledger.new(:ledger_name => 'MatchMint Ledger')
    @total_coins = 0
    @time_elapsed = 0
    @exchange = CentralizedExchange.new
  end

  def mint(params = {:face_value => 1})
    coin = MatchMintCoin.new(:face_value => params[:face_value])
    while @exchange.is_already_minted_coin?(coin)
      puts 'This coin has already been minted, so it will not be added to the exchange, or added to the ledger.'
      coin = MatchMintCoin.new(coin_face_value)
    end
    @ledger = Ledger.new(:ledger_name => 'MatchMint Ledger') if @ledger.nil?
    @exchange.coins << coin 
    @total_coins = @total_coins + params[:face_value]
    ledger_entry_block = LedgerEntryBlock.new(LedgerEntryBlock::DEBIT, coin)
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
  field :created_at
  field :face_value
  has_one :crypto_card, :as => :crypto_card_carrier 

  #attr_accessor :serial_number
  #attr_writer :created_at
  #attr_accessor :face_value
  #attr_accessor :crypto_card 
  after_create :do_crypto_card

  def initialize(params = ({face_value: 1, serial_number: SecureRandom.uuid}))
    if params['face_value'].nil?
      params['face_value'] = 1
    end
    if params['serial_number'].nil?
      params['serial_number'] = SecureRandom.uuid
    end
    #crypto_card = MatchThatCryptography.new(:card_name => "coin card")
    #@crypto_card = crypto_card.save 
    #params[:crypto_card] = @crypto_card
    super(params)
  end
  
  def do_crypto_card
    crypto_card = MatchThatCryptography.new(:card_name => "coin card")
    crypto_card.crypto_card_carrier = self
    @crypto_card = crypto_card.save 
  end
end

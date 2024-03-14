
require '../../config/environment'
require 'mongoid'
require_relative 'mint'
require_relative 'digital_wallet'


puts 'wallet is '
wallet = DigitalWallet.new
wallet.save
puts wallet.inspect

coins = []
coin = MatchMintCoin.new(:digital_wallet => wallet)
#coin.load_defaults
coin.save
puts "saved coin"
puts coin.serial_number.to_s
coins << coin
exchange = CentralizedExchange.new(coins)

coins = MatchMintCoin.all
for coin in coins
  puts "in for coins"
  puts coin.serial_number.to_s
end

crypto_card = MatchThatCryptography.new
crypto_card.crypto_card_carrier = coin
crypto_card.save
puts 'crypto card is '
puts crypto_card.errors.inspect
puts crypto_card.inspect


matches = Match.all
for match in matches
  puts match.title
end

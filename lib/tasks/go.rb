
require '../../config/environment'
require 'mongoid'
require_relative 'mint'
require_relative 'digital_wallet'


puts 'wallet is '
mint_wallet = DigitalWallet.new(:wallet_name => "temp Mint wallet")
mint_wallet.save
puts mint_wallet.inspect

coins = []
coin = MatchMintCoin.new(:digital_wallet => mint_wallet)
#coin.load_defaults
coin.save
coin_before_private_key = coin.crypto_card.private_key
coin_before_public_key = coin.crypto_card.public_key

puts "saved coin"
puts coin.serial_number.to_s
mint_wallet.debit_coin(coin)
coins << coin
exchange = CentralizedExchange.new(coins)

#coins = MatchMintCoin.all
#for coin in coins
#  puts "in for coins"
#  puts coin.serial_number.to_s
#end

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
bank_wallet = DigitalWallet.new(:wallet_name => 'Tempt Bank Wallet')
bank_wallet.save


CentralizedExchange.transfer(mint_wallet, bank_wallet, coin.serial_number)

coin = coin.reload
coin.crypto_card.reload
puts coin.reload.inspect

if coin.crypto_card.private_key == coin_before_private_key
  puts "THE KEYS ARE EQUAL _ FAILED"
else
  puts "THE KEYS ARE NOT EQUAL _ PASSED"
end
if coin.crypto_card.public_key == coin_before_public_key
  puts "THE KEYS ARE EQUAL _ FAILED"
else
  puts "THE KEYS ARE NOT EQUAL _ PASSED"
end

puts bank_wallet.check_balance
if bank_wallet.wallet_identification == coin.digital_wallet.wallet_identification
  puts "coins transferred to bank wallet"
else
  puts "coins not transferred"
end

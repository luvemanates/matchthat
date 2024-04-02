require_relative '../../config/environment'
require 'mongoid'
require_relative 'digital_wallet'
require_relative 'centralized_exchange'

mint_wallet = DigitalWallet.where(:wallet_name => 'Mint Wallet').first
bank_wallet = DigitalWallet.where(:wallet_name => 'Bank Wallet').first
puts bank_wallet.inspect
puts mint_wallet.inspect

CentralizedExchange.make_change(bank_wallet, 1.50)
puts bank_wallet.reload.inspect
puts mint_wallet.reload.inspect

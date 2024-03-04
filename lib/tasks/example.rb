require_relative 'digital_wallet'
require_relative 'mint'
require_relative 'matchthat_cryptography'
require_relative 'ledger'
require_relative 'centralized_exchange'

coins = []
coin = MatchMintCoin.new
coins << coin
exchange = CentralizedExchange.new(coins)


blocks = []
ledger_entry_block = LedgerEntryBlock.new( LedgerEntryBlock::DEBIT, coin)
blocks << ledger_entry_block
ledger_entry_block = LedgerEntryBlock.new( LedgerEntryBlock::DEBIT, coin)
blocks << ledger_entry_block
ledger_entry_block = LedgerEntryBlock.new( LedgerEntryBlock::CREDIT, coin)
blocks << ledger_entry_block

ledger = Ledger.new('Random Ledger', blocks, 2)

#this comes back with two coins - but the wallet should reflect the real sum of face value amounts
puts ledger.ledger_name + " has amount: " + ledger.current_ledger_amount.to_s


crypto_config = {
  :key_length  => 4096,
  :digest_func => OpenSSL::Digest::SHA256.new
}

crypto = MatchThatCryptography.new(crypto_config)

mint_wallet_crypto_card = crypto.make_party("Mint Wallet")
bank_wallet_crypto_card = crypto.make_party("Bank Wallet")

mint_wallet = DigitalWallet.new('Mint Wallet', mint_wallet_crypto_card) 
bank_wallet = DigitalWallet.new('Bank Wallet', bank_wallet_crypto_card) 

mint_wallet.debit_coin(coin)


random_secret = (0...16).map { (65 + rand(26)).chr }.join
matchthat_crypto = MatchThatCryptography.new
other_secret = matchthat_crypto.process_message(common, mint_wallet_crypto_card, bank_wallet_crypto_card, "Requesting deposit authorization:", random_secret)
if( random_secret == other_secret )
  CentralizedExchange.transfer( mint_wallet, bank_wallet, 1)
  bank_wallet.check_balance
  mint_wallet.check_balance
end


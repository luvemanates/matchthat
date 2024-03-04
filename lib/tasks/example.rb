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

mint_crypto_card = MatchThatCryptography.new
mint_wallet = DigitalWallet.new('Mint Wallet', mint_crypto_card) 
mint_wallet.debit_coin(coin)

bank_crypto_card = MatchThatCryptography.new
bank_wallet = DigitalWallet.new('Bank Wallet', bank_crypto_card) 

CentralizedExchange.transfer( mint_wallet, bank_wallet, 1)

bank_wallet.check_balance
mint_wallet.check_balance

require_relative 'digital_wallet'
require_relative 'mint'
require_relative 'matchthat_cryptography'
require_relative 'ledger'

coin = MatchMintCoin.new
blocks = []
ledger_entry_block = LedgerEntryBlock.new( LedgerEntryBlock::DEBIT, 1, coin)
blocks << ledger_entry_block
ledger_entry_block = LedgerEntryBlock.new( LedgerEntryBlock::DEBIT, 1, coin)
blocks << ledger_entry_block
ledger_entry_block = LedgerEntryBlock.new( LedgerEntryBlock::CREDIT, 1, coin)
blocks << ledger_entry_block

ledger = Ledger.new('Random Ledger', blocks, 2)

puts ledger.ledger_name + " has amount: " + ledger.current_ledger_amount.to_s

mint_crypto_card = MatchThatCryptography.new
mint_wallet = DigitalWallet.new('Mint Wallet', mint_crypto_card) 
mint_wallet.debit_coin(coin)

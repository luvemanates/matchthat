require_relative 'mint'
require_relative 'blockchain'
require_relative 'digital_wallet'
require_relative 'matchthat_cryptography'

common = {
  :key_length  => 4096,
  :digest_func => OpenSSL::Digest::SHA256.new
}

blockchain = Blockchain.new
mint = MatchMint.new(1)
matchthat_crypto = MatchThatCryptography.new
mint_wallet_crypto_card = matchthat_crypto.make_party(common, "Mint Wallet")
bank_wallet_crypto_card = matchthat_crypto.make_party(common, "Bank Wallet")
mint_wallet = DigitalWallet.new('mint_wallet', mint_wallet_crypto_card)
bank_wallet = DigitalWallet.new('bank_wallet', bank_wallet_crypto_card)
time = 0
while(true) #thread = Thread.new { 
  sleep 1; 
  time = time + 1
  mint.mint(1)  
  added_block = blockchain.add_block("New MatchCoin minted: +1 matchcoin")
  random_secret = (0...16).map { (65 + rand(26)).chr }.join
  random_secret = matchthat_crypto.process_message(common, mint_wallet_crypto_card, bank_wallet_crypto_card, "Requesting deposit authorization:", random_secret)
  puts
  puts "This is where a shared secret auth number should be communicated"
  other_secret = matchthat_crypto.process_message(common, bank_wallet_crypto_card, mint_wallet_crypto_card, "Confirming deposit authorization.", random_secret)
  if( random_secret == other_secret )
    mint_wallet.add_funds(1) #this is where we need encrypted TX
    mint_wallet.check_balance
    bank_wallet.add_funds(mint_wallet.withdraw_funds(1))
    bank_wallet.check_balance
  end

  puts "Block ##{added_block.index}"
  puts "Timestamp: #{added_block.timestamp}"
  puts "Data: #{added_block.data}"
  puts "Previous Hash: #{added_block.previous_hash}"
  puts "Hash: #{added_block.hash}"
  puts "\n"
end



puts


#wallet.withdraw_funds(50)
#wallet.check_balance
#wallet.withdraw_funds(70)
#wallet.check_balance


# Create a new blockchain

# Add some blocks to the blockchain
#blockchain.add_block("Transaction Data 1")
#blockchain.add_block("Transaction Data 2")

# Display the blockchain
=begin
blockchain.chain.each  do |block|
  puts "Block ##{block.index}"
  puts "Timestamp: #{block.timestamp}"
  puts "Data: #{block.data}"
  puts "Previous Hash: #{block.previous_hash}"
  puts "Hash: #{block.hash}"
  puts "\n"
end
=end

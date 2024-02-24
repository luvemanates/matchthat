require_relative 'mint'
require_relative 'blockchain'
require_relative 'digital_wallet'

blockchain = Blockchain.new
mint = MatchMint.new(1)
bank_wallet = DigitalWallet.new
time = 0
while(true) #thread = Thread.new { 
  sleep 1; 
  time = time + 1
  mint.mint(1)  
  added_block = blockchain.add_block("New MatchCoin minted: +1 matchcoin")
  bank_wallet.add_funds(1) #this is where we need encrypted TX
  bank_wallet.check_balance

  puts "Block ##{added_block.index}"
  puts "Timestamp: #{added_block.timestamp}"
  puts "Data: #{added_block.data}"
  puts "Previous Hash: #{added_block.previous_hash}"
  puts "Hash: #{added_block.hash}"
  puts "\n"
end

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

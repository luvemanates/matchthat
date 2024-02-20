require_relative 'blockchain'
require_relative 'digital_wallet'

wallet = DigitalWallet.new
wallet.add_funds(100)
wallet.check_balance
wallet.withdraw_funds(50)
wallet.check_balance
wallet.withdraw_funds(70)
wallet.check_balance


# Create a new blockchain
blockchain = Blockchain.new

# Add some blocks to the blockchain
blockchain.add_block("Transaction Data 1")
blockchain.add_block("Transaction Data 2")

# Display the blockchain
blockchain.chain.each  do |block|
  puts "Block ##{block.index}"
  puts "Timestamp: #{block.timestamp}"
  puts "Data: #{block.data}"
  puts "Previous Hash: #{block.previous_hash}"
  puts "Hash: #{block.hash}"
  puts "\n"
end

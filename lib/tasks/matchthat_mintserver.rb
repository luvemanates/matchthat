
require 'socket'
require 'json'
require_relative 'mint'
require_relative 'matchthat_cryptography'
require_relative 'digital_wallet'



server = TCPServer.new(2000) # Bind to port 2000
mint = MatchMintingBank.new 
matchthatmint_crypto = MatchThatCryptography.new(MatchThatCryptography::CONFIG)
mint_wallet = DigitalWallet.new('mint_wallet', matchthatmint_crypto)
exchange = CentralizedExchange.new

random_secret = (0...16).map { (65 + rand(26)).chr }.join



loop {
  client = server.accept
  params = JSON.parse(client.gets)
  if not params[:public_key].nil?
    #other_secret = matchthat_crypto.encrypt_message(mint_wallet_crypto_card, params[:public_key], "Requesting deposit authorization:", random_secret)
  end
  puts "the public key from the client is "
  #client.puts params[:public_key ]
  puts params["public_key"]
  #raise params.inspect
  puts "params is"
  puts params

}

=begin
loop do
  client = server.accept    # Wait for a client to connect
  # Send a message to the client
  coin = mint.mint(1)
  exchange.coins << coin
  mint_wallet.debit_coin(coin)
  CentralizedExchange.transfer( mint_wallet, bank_wallet, 1)
  bank_wallet.check_balance
  mint_wallet.check_balance
  client.puts "Hello from the TCP server!"
  client.close
end
=end

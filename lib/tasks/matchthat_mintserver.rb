
require 'socket'
require 'json'
require_relative 'mint'
require_relative 'matchthat_cryptography'
require_relative 'digital_wallet'



host = 'localhost'
port = 2000
server = TCPServer.open(host, port) # Bind to port 2000
mint = MatchMintingBank.new 
matchthatmint_crypto = MatchThatCryptography.new(MatchThatCryptography::CONFIG)
#matchthatbank_crypto = MatchThatCryptography.new(MatchThatCryptography::CONFIG)
mint_wallet = DigitalWallet.new('mint_wallet', matchthatmint_crypto)
exchange = CentralizedExchange.new

random_secret = (0...16).map { (65 + rand(26)).chr }.join
puts "random secret is " + random_secret.to_s

def encode64(string)
  string = string.to_s unless string.is_a?(String)
  Base64.encode64(string)
end

def decode64(string)
  string = string.to_s unless string.is_a?(String)
  Base64.decode64(string)
end

loop {
  client = server.accept
  params = JSON.parse(client.gets)
  if not params["public_key"].nil?
    puts "the public key from the client is "
    puts params["public_key"]
    client_public_key = decode64( params["public_key"] )
    #other_secret = matchthat_crypto.encrypt_message(mint_wallet_crypto_card, params[:public_key], "Requesting deposit authorization:", random_secret)
    encrypted_message = matchthatmint_crypto.encrypt_message_with_recipient_public_key(client_public_key, random_secret)
#    decrypted_message = matchthatbank_crypto.decrypt_message_with_private_key(encrypted_message)
    puts 'encrypted message ' 
    puts 'encoding is ' 
    puts encrypted_message.encoding
#    encrypted_message = "See if this is even recieved"
    #puts encrypted_message
    encrypted_message_utf8 = encode64(encrypted_message)
    puts "sending message with encoding " 
    puts encrypted_message_utf8.encoding
    client.puts({'encrypted_message' => encrypted_message_utf8}.to_json)
    params = JSON.parse(client.gets)
    puts "returning from client after decrypt"
    puts params
  end
  #client.puts params[:public_key ]
  #raise params.inspect
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


require 'socket'
require 'json'
require_relative 'mint'
require_relative 'matchthat_cryptography'
require_relative 'digital_wallet'




def encode64(string)
  string = string.to_s unless string.is_a?(String)
  Base64.encode64(string)
end

def decode64(string)
  string = string.to_s unless string.is_a?(String)
  Base64.decode64(string)
end

class MintServer
  

  def initialize
  end


  def run
    host = 'localhost'
    port = 2000
    server = TCPServer.open(host, port) # Bind to port 2000
    mint = MatchMintingBank.new 
    matchthatmint_crypto = MatchThatCryptography.new(MatchThatCryptography::CONFIG)
    #matchthatbank_crypto = MatchThatCryptography.new(MatchThatCryptography::CONFIG)
    mint_wallet = DigitalWallet.new('mint_wallet', matchthatmint_crypto)
    exchange = CentralizedExchange.new

    matchthat_cipher = MatchThatCipher.new
    matchthat_cipher.setup_cipher()

    random_secret = matchthat_cipher.cipher_key #(0...16).map { (65 + rand(26)).chr }.join
    puts "random secret is " + random_secret.to_s

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
        encrypted_cipher_iv = matchthatmint_crypto.encrypt_message_with_recipient_public_key(client_public_key, matchthat_cipher.cipher_iv)
        client.puts({'encrypted_cipher' => encrypted_message_utf8, "encrypted_cipher_iv" => encode64(encrypted_cipher_iv)}.to_json)

        #params = JSON.parse(client.gets)
        #puts "returning from client after decrypt"
        #puts params
        client.puts({'public_key' => encode64(matchthatmint_crypto.public_key.to_s)}.to_json)
      end
      params = JSON.parse(client.gets)
      puts "params parsed"
      puts params
      client_response = decode64(params["encrypted_secret"])
      decrypted_message = matchthatmint_crypto.decrypt_message_with_private_key(client_response)
      puts decrypted_message
      puts "VERIFIED" if decrypted_message == random_secret

      #client.puts params[:public_key ]
      #raise params.inspect
      data = "I sent this message - later it should turn into a coin"
      ciphered_message = matchthat_cipher.encrypt_with_cipher(data) 
      ciphered_message = encode64(ciphered_message)
      client.puts({'ciphered_message' => ciphered_message}.to_json)
    }

    client.close

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
  end
end

ms = MintServer.new
ms.run


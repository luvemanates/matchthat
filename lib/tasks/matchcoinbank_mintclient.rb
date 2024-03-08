require 'socket'
require 'json'
require_relative 'matchthat_cryptography'
require_relative 'digital_wallet'
require_relative 'centralized_exchange'


def encode64(string)
  string = string.to_s unless string.is_a?(String)
  Base64.encode64(string)
end

def decode64(string)
  string = string.to_s unless string.is_a?(String)
  Base64.decode64(string)
end

class MintClientBank

  attr_accessor :bank_client
  attr_accessor :bank_crypto
  attr_accessor :bank_wallet
  attr_accessor :cipher
  attr_accessor :cipher_key
  attr_accessor :ciphera_iv

  def initialize
    @bank_crypto = MatchThatCryptography.new(MatchThatCryptography::CONFIG)
    @bank_wallet = DigitalWallet.new('Bank Wallet', @bank_crypto)
    @exchange = CentralizedExchange.new
  end

  #so one way to transfer funds would be to have a secret inside the coin that is
  #sent to the CentralExchange which authorizes any transfers - and stores the wallet
  #its currently cointained in
  #so the central exchange authorizes and stores the new wallet info for that coin
  #maybe a central exchange should be allowed to lock coins that way nothing can happen to it
  #in the middle of transfer
  def run
    loop do
      response = @bank_client.gets
      puts "response is "
      puts response
      params = JSON.parse(response) unless response.nil?
      data = {}

      @decipher = MatchThatCipher.new
      
      @decipher.setup_decipher(@cipher_key, @cipher_iv)

      data["wallet_identification"] = @decipher.decrypt_with_cipher(decode64(params["wallet_identification"]))
      data["coin_serial_number"] = @decipher.decrypt_with_cipher(decode64(params["coin_serial_number"]))
      data["coin_face_value"] = @decipher.decrypt_with_cipher(decode64(params["coin_face_value"]))
      puts "data is "
      puts data
    end
    @bank_client.close
  end

  def secure_connection
    host = 'localhost'
    port = 2000
    @bank_client = TCPSocket.open(host, port)
    request = { 'public_key' => encode64(@bank_crypto.public_key) }.to_json
    @bank_client.puts(request)
    response = @bank_client.gets
    params = JSON.parse(response) unless response.nil?
    puts "params is "
    puts params
    #unless not params.nil?
    puts 'in block'
    encrypted_message = params["encrypted_cipher"]
    encrypted_message = decode64(encrypted_message)

    encrypted_iv = params["encrypted_cipher_iv"]

    decrypted_message = @bank_crypto.decrypt_message_with_private_key(encrypted_message)
    @cipher_key = decrypted_message
    decrypted_iv = @bank_crypto.decrypt_message_with_private_key(decode64(encrypted_iv))
    @cipher_iv = decrypted_iv

    puts "\n\n"
    puts "decrypted mesage IS "
    puts decrypted_message

      #here is where we need to get the public key and encrypt it with the decrypted_message
    #end
    response = @bank_client.gets
    params = JSON.parse(response) unless response.nil?
    puts "params is "
    puts params
    server_public_key = decode64(params["public_key"])
    encrypted_secret = @bank_crypto.encrypt_message_with_recipient_public_key(server_public_key, decrypted_message)
    @bank_client.puts( {"encrypted_secret" => encode64(encrypted_secret) }.to_json )
    puts "sent encrypted secret"
    return true


  end
end

mcb = MintClientBank.new
if mcb.secure_connection
  puts "calling run"
  mcb.run
end


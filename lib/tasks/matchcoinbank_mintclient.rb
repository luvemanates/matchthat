require 'socket'
require 'json'
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

class MintClientBank

  def initialize
  end

  def run
    bank_crypto = MatchThatCryptography.new(MatchThatCryptography::CONFIG)
    bank_wallet = DigitalWallet.new('Bank Wallet', bank_crypto)


    host = 'localhost'
    port = 2000
    bank_client_socket = TCPSocket.open(host, port)
    request = { 'public_key' => encode64(bank_crypto.public_key) }.to_json
    bank_client_socket.puts(request)
    response = bank_client_socket.gets
    params = JSON.parse(response) unless response.nil?
    puts "params is "
    puts params
    #unless not params.nil?
      puts 'in block'
      encrypted_message = params["encrypted_cipher"]
      encrypted_message = decode64(encrypted_message)

      encrypted_iv = params["encrypted_cipher_iv"]

      decrypted_message = bank_crypto.decrypt_message_with_private_key(encrypted_message)
      decrypted_iv = bank_crypto.decrypt_message_with_private_key(decode64(encrypted_iv))

      puts "\n\n"
      puts "decrypted mesage IS "
      puts decrypted_message

      #here is where we need to get the public key and encrypt it with the decrypted_message
    #end
    response = bank_client_socket.gets
    params = JSON.parse(response) unless response.nil?
    puts "params is "
    puts params
    server_public_key = decode64(params["public_key"])
    encrypted_secret = bank_crypto.encrypt_message_with_recipient_public_key(server_public_key, decrypted_message)
    bank_client_socket.puts( {"encrypted_secret" => encode64(encrypted_secret) }.to_json )
    puts "sent encrypted secret"

    response = bank_client_socket.gets
    puts "response is "
    puts response
    params = JSON.parse(response) unless response.nil?

    encrypted_message = decode64(params["ciphered_message"])

    cipher = MatchThatCipher.new
    
    cipher.setup_decipher(decrypted_message, decrypted_iv)

    message = cipher.decrypt_with_cipher(encrypted_message)
    puts "message is "
    puts message

    bank_client_socket.close
  end
end

mcb = MintClientBank.new
mcb.run


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

def convert_utf8(string)
  string = string.to_s unless string.is_a?(String)
  string.force_encoding("ISO-8859-1").encode("UTF-8")

end

def convert_ascii8bit(string)
  string = string.to_s unless string.is_a?(String)
  string.force_encoding("UTF-8").encode('ASCII-8BIT')
end


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
  encrypted_message = params["encrypted_message"]
  encrypted_message = decode64(encrypted_message)

  decrypted_message = bank_crypto.decrypt_message_with_private_key(encrypted_message)
  puts "decrypted message"
  puts "\n\n"
  puts "decrypted mesage IS "
  puts decrypted_message

  #here is where we need to get the public key and encrypt it with the decrypted_message
#end
bank_client_socket.close







#Below an example of client server comunication via json. You will expect something like this RuntimeError: {"method1"=>"param1"}. Instead of raising errors, process this json with the server logic.

#Server

=begin
require 'socket'
require 'json'

server = TCPServer.open(2000)
loop {
  client = server.accept
  params = JSON.parse(client.gets)
  raise params.inspect
}

Client

require 'socket'
require 'json'

host = 'localhost'
port = 2000

s = TCPSocket.open(host, port)

request = { 'method1' => 'param1' }.to_json
s.print(request)

=end

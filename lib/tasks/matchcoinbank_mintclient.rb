require 'socket'
require 'json'
require_relative 'matchthat_cryptography'
require_relative 'digital_wallet'

bank_crypto = MatchThatCryptography.new(MatchThatCryptography::CONFIG)
bank_wallet = DigitalWallet.new('Bank Wallet', bank_crypto)


host = 'localhost'
port = 2000
client_socket = TCPSocket.open(host, port)
request = { 'public_key' => bank_crypto.public_key }.to_json
client_socket.print(request)
client_socket.close







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

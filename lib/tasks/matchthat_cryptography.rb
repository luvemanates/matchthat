
require 'base64'
require 'openssl'


class MatchThatCryptography

  def initialize
  end

  def make_party(conf, name)
    # create a public/private key pair for this party
    pair = OpenSSL::PKey::RSA.new(conf[:key_length])

    # extract the public key from the pair
    pub  = OpenSSL::PKey::RSA.new(pair.public_key.to_der)

    { :keypair => pair, :pubkey => pub, :name => name }

  end

  def process_message(conf, from_party, to_party, message, secret)

    # using the sender's private key, generate a signature for the message
    signature = from_party[:keypair].sign(conf[:digest_func], message)

    # messages are encrypted (by the sender) using the recipient's public key
    encrypted_message = to_party[:pubkey].public_encrypt(message)
    encrypted_secret = to_party[:pubkey].public_encrypt(secret)

    # messages are decrypted (by the recipient) using their private key
    decrypted = to_party[:keypair].private_decrypt(encrypted_message)
    decrypted_secret = to_party[:keypair].private_decrypt(encrypted_secret)

    puts "Signature:"
    puts Base64.encode64(signature)

    puts
    puts "Encrypted:"
    puts Base64.encode64(encrypted_message)

    puts
    puts "From: #{from_party[:name]}"
    puts "To  : #{to_party[:name]}"

    puts
    puts "Decrypted:"
    puts decrypted

    if from_party[:pubkey].verify(conf[:digest_func], signature, decrypted)
            puts "Verified!"
    end
    return decrypted_secret

  end
end


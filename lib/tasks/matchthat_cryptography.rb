
require 'base64'
require 'openssl'


class MatchThatCryptography

  CONFIG = {
    :key_length  => 4096,
    :digest_func => OpenSSL::Digest::SHA256.new
  }

  attr_accessor :config
  attr_accessor :keypair
  attr_accessor :public_key
  attr_accessor :card_name

  def initialize(conf=CONFIG)
    @config = conf
    @keypair = OpenSSL::PKey::RSA.new(@config[:key_length])
    @public_key  = OpenSSL::PKey::RSA.new(@keypair.public_key.to_der)
    @name = 'default card'
  end

=begin
  def make_party(name)
    # create a public/private key pair for this party

    # extract the public key from the pair

    { :keypair => @pair, :pubkey => @public_key, :name => @card_name }

  end
=end

  def encrypt_message_with_recipient_public_key(recipient_public_key, message)
    recipient_public_key  = OpenSSL::PKey::RSA.new(recipient_public_key)
    encrypted_message = recipient_public_key.public_encrypt(message)
    #encrypted_secret = to_party[:pubkey].public_encrypt(secret)
  end

  def decrypt_message_with_private_key(encrypted_message)
    decrypted_message = @keypair.private_decrypt(encrypted_message)
    return decrypted_message
  end

  def process_message(conf, from_party, to_party, message, secret)

    # using the sender's private key, generate a signature for the message
    signature = from_party[:keypair].sign(conf[:digest_func], message)

    # messages are encrypted (by the sender) using the recipient's public key
    encrypted_message = to_party[:pubkey].public_encrypt(message)
    encrypted_secret = to_party[:pubkey].public_encrypt(secret)

    #this is where the code needs to break, and the encrypted data sent tot he client

    # messages are decrypted (by the recipient) using their private key
    decrypted = to_party[:keypair].private_decrypt(encrypted_message)
    decrypted_secret = to_party[:keypair].private_decrypt(encrypted_secret)

    puts "Signature:"
    puts Base64.encode64(signature)

    puts
    puts "Encrypted:"
    puts Base64.encode64(encrypted_message)

    puts
    puts "From: #{from_party[:card_name]}"
    puts "To  : #{to_party[:card_name]}"

    puts
    puts "Decrypted:"
    puts decrypted

    if from_party[:pubkey].verify(@config[:digest_func], signature, decrypted)
            puts "Verified!"
    end
    return decrypted_secret

  end
end

class MatchThatCipher

  attr_accessor :cipher
  attr_accessor :cipher_key
  attr_accessor :cipher_iv
  attr_accessor :decipher

  def initialize
  end

  def setup_cipher
    @cipher = OpenSSL::Cipher::AES.new(128, :CBC)
    @cipher.encrypt
    @cipher_key = @cipher.random_key
    @cipher_iv = @cipher.random_iv
  end

  def encrypt_with_cipher(data)
    encrypted = @cipher.update(data) + @cipher.final
    return encode64(encrypted)
  end

  def setup_decipher(key, iv)
    @decipher = OpenSSL::Cipher::AES.new(128, :CBC)
    @decipher.decrypt
    @decipher.key = key
    @decipher.iv = iv
  end

  def decrypt_with_cipher(encrypted_data)
    data_to_decrypt = decode64(encrypted_data)
    plain = @decipher.update( data_to_decrypt ) + @decipher.final
    return plain
  end
end

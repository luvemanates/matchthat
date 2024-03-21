
require 'mongoid'
require 'base64'
require 'openssl'


class MatchThatCryptography

  include Mongoid::Document
  include Mongoid::Timestamps

  CONFIG = {
    :key_length  => 4096,
    :digest_func => OpenSSL::Digest::SHA256.new
  }

  belongs_to :crypto_card_carrier, :polymorphic => true


  field :private_key
  field :public_key
  field :card_name

  attr_accessor :config
  attr_accessor :ss_private_key
  attr_accessor :ss_public_key
  attr_accessor :logger

  after_find :init_logger
  before_create :init_logger

  def initialize(params={:card_name => 'default card'})
    keypair = OpenSSL::PKey::RSA.new(CONFIG[:key_length])
    @private_key = Base64.encode64(keypair.private_to_pem)
    @public_key  = Base64.encode64(keypair.public_to_pem) #OpenSSL::PKey::RSA.new(@keypair.public_key.to_der)
    @card_name = params[:card_name] 
    params[:private_key] = @private_key
    params[:public_key] = @public_key
    params[:card_name] = @card_name
    super(params)
  end

  def init_logger
    @logger = Logger.new(Logger::DEBUG)
    @logger.debug("initialized logger in digital wallet")
  end

  #need to decode and objectify database data - it would be nice to use the marshalling method
  def ssobject_load
    @ss_private_key = OpenSSL::PKey::RSA.new( Base64.decode64( @private_key) )
    @ss_public_key = OpenSSL::PKey::RSA.new( Base64.decode64( @public_key) )
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

  def encrypt_message_with_public_key(message)
    if @public_key.is_a?(String)
      @public_key = OpenSSL::PKey::RSA.new( Base64.decode64( @public_key) )
    end
    encrypted_message = @public_key.public_encrypt(message)
    return encrypted_message
    #encrypted_secret = to_party[:pubkey].public_encrypt(secret)
  end

  def decrypt_message_with_private_key(encrypted_message)
    if @private_key.is_a?(String)
      @private_key = OpenSSL::PKey::RSA.new( Base64.decode64( @private_key) )
    end
    decrypted_message = @private_key.private_decrypt(encrypted_message)
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

    @logger.debug "Signature:"
    @logger.debug Base64.encode64(signature)

    @logger.debug '\n'
    @logger.debug "Encrypted:"
    @logger.debug Base64.encode64(encrypted_message)

    @logger.debug '\n'
    @logger.debug "From: #{from_party[:card_name]}"
    @logger.debug "To  : #{to_party[:card_name]}"

    @logger.debug 
    @logger.debug "Decrypted:"
    @logger.debug decrypted

    if from_party[:pubkey].verify(CONFIG[:digest_func], signature, decrypted)
      @logger.debug "Verified!"
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

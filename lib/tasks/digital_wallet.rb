class DigitalWallet
  attr_reader :balance
  attr_accessor :crypto_card
  attr_accessor :wallet_name

  def initialize(wallet_name, crypto_card)
    @balance = 0
    @crypto_card = crypto_card
    @wallet_name = wallet_name
  end

  def add_funds(amount)
    if amount > 0
      @balance += amount
      puts "Added #{amount} to your " + @wallet_name.to_s + " wallet."
    else
      puts "Invalid amount in #{@wallet_name}. Please enter a positive number."
    end
  end

  def withdraw_funds(amount)
    if amount <= @balance && amount > 0
      @balance -= amount
      puts "Withdrawn #{amount} from your " + @wallet_name.to_s + " wallet."
    elsif amount <= 0
      puts "Invalid amount in " + @wallet_name.to_s + " Please enter a positive number."
    else
      puts "Insufficient funds in " + @wallet_name.to_s + "."
    end
    return amount
  end

  def check_balance
    puts "The current balance of " + @wallet_name.to_s + " #{@balance}."
  end
end


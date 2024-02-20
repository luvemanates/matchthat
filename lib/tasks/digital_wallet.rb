class DigitalWallet
  attr_reader :balance

  def initialize
    @balance = 0
  end

  def add_funds(amount)
    if amount > 0
      @balance += amount
      puts "Added #{amount} to your wallet."
    else
      puts "Invalid amount. Please enter a positive number."
    end
  end

  def withdraw_funds(amount)
    if amount <= @balance && amount > 0
      @balance -= amount
      puts "Withdrawn #{amount} from your wallet."
    elsif amount <= 0
      puts "Invalid amount. Please enter a positive number."
    else
      puts "Insufficient funds."
    end
  end

  def check_balance
    puts "Your current balance is #{@balance}."
  end
end


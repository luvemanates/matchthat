class MatchMint
  attr_accessor :time_elapsed
  attr_accessor :total_coins

  def initialize(initial_coin_amount)
    @total_coins = initial_coin_amount
    @time_elapsed = 0
  end

  def mint(new_coin_amount)
    @total_coins = @total_coins + new_coin_amount
  end

end

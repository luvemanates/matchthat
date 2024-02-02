require "test_helper"

class MatchTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  test "can create a match with a user" do
    @user = User.new(:email => 'blah@blah.com', :password => 'deftones', :password_confirmation => 'deftones')
    assert_difference("User.count") do
      @user.save
    end
    @user.save
    assert_difference("Match.count") do
      @match = Match.new(:title => "Radio", :total_amount => 0.0, :description => "Radio is worth at least a thousand", :base_amount => 1000.00, :creator_id => @user.id)
      assert @match.save
    end
  end
end

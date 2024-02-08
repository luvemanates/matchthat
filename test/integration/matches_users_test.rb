require "test_helper"

class MatchesUsersTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end
  test "should create match" do
    @nuser = User.new(:email => "james@frankg.com", :password => 'deftones', :password_confirmation => 'deftones')
    assert_difference("User.count") do
      @nuser.save
    end
    post user_session_path, :params => {:user => { :email => @nuser.email, :password => 'deftones' }}
    assert_redirected_to root_path
    assert_difference("Match.count") do
      post matches_url, params: { match: { base_amount: 30, creator_id: @nuser.id, description: "Sweet fries should be worth more", title: "Sweet potato fries", total_amount: 2000 } }
    end

    assert_redirected_to match_url(Match.last)
  end
end

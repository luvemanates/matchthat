require "test_helper"

class MatchesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @match = matches(:one)
  end

  test "should get index" do
    get matches_url
    assert_response :success
  end

  test "should get new" do
    get new_match_url
    assert_response :success
  end

  test "should create match" do
    @user = User.new(:email => "frank@frankg.com", :password => 'deftones', :password_confirmation => 'deftones')
    assert_difference("User.count") do
      @user.save
    end
    post user_session, :params { :email => 'frank@frankg.com', :password => 'deftones' }
    assert_difference("Match.count") do
      post matches_url, params: { match: { base_amount: @match.base_amount, creator_id: @user.id, description: @match.description, title: @match.title, total_amount: @match.total_amount } }
    end

    assert_redirected_to match_url(Match.last)
  end

  test "should show match" do
    get match_url(@match)
    assert_response :success
  end

  test "should get edit" do
    get edit_match_url(@match)
    assert_response :success
  end

  test "should update match" do
    patch match_url(@match), params: { match: { base_amount: @match.base_amount, creator_id: @match.creator_id, description: @match.description, title: @match.title, total_amount: @match.total_amount } }
    assert_redirected_to match_url(@match)
  end

  test "should destroy match" do
    assert_difference("Match.count", -1) do
      delete match_url(@match)
    end

    assert_redirected_to matches_url
  end
end

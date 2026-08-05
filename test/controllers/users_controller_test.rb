require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    sign_in @user
  end

  test "should get index" do
    get users_path
    assert_response :success
  end

  test "should get show" do
    get user_path(@user)
    assert_response :success
  end
end

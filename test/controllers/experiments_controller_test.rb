require "test_helper"

class ExperimentsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get experiments_index_url
    assert_response :success
  end

  test "should get show" do
    get experiments_show_url
    assert_response :success
  end

  test "should get lab" do
    get experiments_lab_url
    assert_response :success
  end
end

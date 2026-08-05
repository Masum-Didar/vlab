require "test_helper"

class ExperimentResultsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    sign_in @user
    @result = experiment_results(:one)
  end

  test "should get index" do
    get experiment_results_path
    assert_response :success
  end

  test "should get show" do
    get experiment_result_path(@result)
    assert_response :success
  end
end

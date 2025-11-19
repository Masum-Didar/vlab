require "test_helper"

class ExperimentResultsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get experiment_results_index_url
    assert_response :success
  end

  test "should get show" do
    get experiment_results_show_url
    assert_response :success
  end
end

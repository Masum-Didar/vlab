require "test_helper"

class ExperimentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    sign_in @user
    @experiment = experiments(:one)
    @experiment.update!(published: true)
  end

  test "should get index" do
    get experiments_url
    assert_response :success
  end

  test "should get show" do
    get experiment_url(@experiment)
    assert_response :success
  end

  test "should get lab" do
    get lab_experiment_url(@experiment)
    assert_response :success
  end
end

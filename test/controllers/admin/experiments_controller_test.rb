require "test_helper"

class Admin::ExperimentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:faculty_one)
    sign_in @user
    @experiment = experiments(:one)
  end

  test "should get index" do
    get admin_experiments_url
    assert_response :success
  end

  test "should get show" do
    get admin_experiment_url(@experiment)
    assert_response :success
  end

  test "should get new" do
    get new_admin_experiment_url
    assert_response :success
  end

  test "should create experiment" do
    assert_difference("Experiment.count") do
      post admin_experiments_url, params: { experiment: { title: "New Lab", description: "Testing", difficulty: 1, duration: 30, published: false } }
    end
    assert_redirected_to admin_experiments_path
  end

  test "should get edit" do
    get edit_admin_experiment_url(@experiment)
    assert_response :success
  end

  test "should update experiment" do
    patch admin_experiment_url(@experiment), params: { experiment: { title: "Updated Lab Name" } }
    assert_redirected_to admin_experiments_path
  end

  test "should destroy experiment" do
    assert_difference("Experiment.count", -1) do
      delete admin_experiment_url(@experiment)
    end
    assert_redirected_to admin_experiments_path
  end
end

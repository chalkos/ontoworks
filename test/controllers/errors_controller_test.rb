require 'test_helper'

class ErrorsControllerTest < ActionController::TestCase
  test "should get not_found" do
    get :not_found
    assert_response :success
  end

  test "should get internal_server_error" do
    get :internal_server_error
    assert_response :success
  end

  test "should get unprocessable_entity" do
    get :unprocessable_entity
    assert_response :success
  end

end

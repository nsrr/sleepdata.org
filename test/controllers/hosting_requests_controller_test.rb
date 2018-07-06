# frozen_string_literal: true

require "test_helper"

# Tests to assure admins can review hosting requests.
class HostingRequestsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @hosting_request = hosting_requests(:one)
    login(users(:admin))
  end

  def hosting_request_params
    {
      institution_name: @hosting_request.institution_name,
      description: @hosting_request.description,
      reviewed: "1"
    }
  end

  test "should get index" do
    get hosting_requests_url
    assert_not_nil assigns(:hosting_requests)
    assert_response :success
  end

  # test "should get new" do
  #   get new_hosting_request_url
  #   assert_response :success
  # end

  # test "should create hosting_request" do
  #   assert_difference("HostingRequest.count") do
  #     post hosting_requests_url, params: { hosting_request: hosting_request_params }
  #   end
  #   assert_redirected_to hosting_request_url(assigns(:hosting_request))
  # end

  test "should show hosting_request" do
    get hosting_request_url(@hosting_request)
    assert_response :success
  end

  test "should get edit" do
    get edit_hosting_request_url(@hosting_request)
    assert_response :success
  end

  test "should update hosting_request" do
    patch hosting_request_url(@hosting_request), params: { hosting_request: hosting_request_params }
    assert_redirected_to hosting_request_url(assigns(:hosting_request))
  end

  test "should destroy hosting_request" do
    assert_difference("HostingRequest.current.count", -1) do
      delete hosting_request_url(@hosting_request)
    end
    assert_redirected_to hosting_requests_url
  end
end

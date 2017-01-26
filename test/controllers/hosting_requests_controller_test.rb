# frozen_string_literal: true

require 'test_helper'

# Tests to assure admins can review hosting requests.
class HostingRequestsControllerTest < ActionController::TestCase
  setup do
    @hosting_request = hosting_requests(:one)
    login(users(:admin))
  end

  def hosting_request_params
    {
      institution_name: @hosting_request.institution_name,
      description: @hosting_request.description,
      reviewed: '1'
    }
  end

  test 'should get index' do
    get :index
    assert_not_nil assigns(:hosting_requests)
    assert_response :success
  end

  # test 'should get new' do
  #   get :new
  #   assert_response :success
  # end

  # test 'should create hosting_request' do
  #   assert_difference('HostingRequest.count') do
  #     post :create, params: { hosting_request: hosting_request_params }
  #   end
  #   assert_redirected_to hosting_request_path(assigns(:hosting_request))
  # end

  test 'should show hosting_request' do
    get :show, params: { id: @hosting_request }
    assert_response :success
  end

  test 'should get edit' do
    get :edit, params: { id: @hosting_request }
    assert_response :success
  end

  test 'should update hosting_request' do
    patch :update, params: { id: @hosting_request, hosting_request: hosting_request_params }
    assert_redirected_to hosting_request_path(assigns(:hosting_request))
  end

  test 'should destroy hosting_request' do
    assert_difference('HostingRequest.current.count', -1) do
      delete :destroy, params: { id: @hosting_request }
    end
    assert_redirected_to hosting_requests_path
  end
end

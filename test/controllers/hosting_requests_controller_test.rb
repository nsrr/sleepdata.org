require 'test_helper'

class HostingRequestsControllerTest < ActionController::TestCase
  setup do
    @hosting_request = hosting_requests(:one)
    login(users(:admin))
  end

  test 'should get index' do
    get :index
    assert_response :success
    assert_not_nil assigns(:hosting_requests)
  end

  # test 'should get new' do
  #   get :new
  #   assert_response :success
  # end

  # test 'should create hosting_request' do
  #   assert_difference('HostingRequest.count') do
  #     post :create, hosting_request: { description: @hosting_request.description, institution_name: @hosting_request.institution_name }
  #   end

  #   assert_redirected_to hosting_request_path(assigns(:hosting_request))
  # end

  test 'should show hosting_request' do
    get :show, id: @hosting_request
    assert_response :success
  end

  test 'should get edit' do
    get :edit, id: @hosting_request
    assert_response :success
  end

  test 'should update hosting_request' do
    patch :update, id: @hosting_request, hosting_request: { description: @hosting_request.description, institution_name: @hosting_request.institution_name }
    assert_redirected_to hosting_request_path(assigns(:hosting_request))
  end

  test 'should destroy hosting_request' do
    assert_difference('HostingRequest.current.count', -1) do
      delete :destroy, id: @hosting_request
    end

    assert_redirected_to hosting_requests_path
  end
end

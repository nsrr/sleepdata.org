require 'test_helper'

# This controller tests simultaneous registration and form submission
class RequestControllerTest < ActionController::TestCase
  test 'should get tool contribute' do
    get :tool_contribute
    assert_response :success
  end

  test 'should get tool request' do
    get :tool_request
    assert_response :success
  end

  test 'should get dataset hosting' do
    get :dataset_hosting
    assert_response :success
  end

  test 'should create dataset hosting request for new user' do
    assert_difference('User.count') do
      assert_difference('HostingRequest.count') do
        post :create_hosting_request, user: { first_name: 'First Name', last_name: 'Last Name', email: 'dataset@hosting.com' }, hosting_request: { description: 'Description', institution_name: 'Institution' }
      end
    end
    assert_redirected_to dataset_hosting_submitted_path
  end

  test 'should create dataset hosting request for logged in user' do
    login(users(:valid))
    assert_difference('User.count', 0) do
      assert_difference('HostingRequest.count') do
        post :create_hosting_request, hosting_request: { description: 'Description', institution_name: 'Institution' }
      end
    end
    assert_redirected_to dataset_hosting_submitted_path
  end

  test 'should not create dataset hosting request for new user with incomplete information' do
    assert_difference('User.count', 0) do
      assert_difference('HostingRequest.count', 0) do
        post :create_hosting_request, user: { first_name: '', last_name: 'Last Name', email: 'dataset@hosting.com' }, hosting_request: { description: 'Description', institution_name: 'Institution' }
      end
    end

    assert_not_nil assigns(:errors)
    assert_equal ["can't be blank"], assigns(:errors)[:first_name]

    assert_template :dataset_hosting
    assert_response :success
  end

  test 'should register user but not create dataset hosting request with incomplete information' do
    assert_difference('User.count', 1) do
      assert_difference('HostingRequest.count', 0) do
        post :create_hosting_request, user: { first_name: 'First Name', last_name: 'Last Name', email: 'dataset@hosting.com' }, hosting_request: { description: '', institution_name: 'Institution' }
      end
    end

    assert_not_nil assigns(:hosting_request)
    assert assigns(:hosting_request).errors.size > 0
    assert_equal ["can't be blank"], assigns(:hosting_request).errors[:description]

    assert_template :dataset_hosting
    assert_response :success
  end

  test 'should get dataset hosting submitted' do
    get :dataset_hosting_submitted
    assert_response :success
  end
end

require 'test_helper'

class AgreementsControllerTest < ActionController::TestCase
  setup do
    @agreement = agreements(:one)

  end

  test "should get index" do
    login(users(:admin))
    get :index
    assert_response :success
    assert_not_nil assigns(:agreements)
  end

  # test "should get new" do
  #   get :new
  #   assert_response :success
  # end

  test "should create agreement" do
    login(users(:editor))
    assert_difference('Agreement.count') do
      post :create, agreement: { dua: fixture_file_upload('../../test/support/agreements/blank.pdf') }
    end

    assert_redirected_to dua_path # agreement_path(assigns(:agreement))
  end

  test "should not create agreement if one already exists" do
    login(users(:valid))
    assert_difference('Agreement.count', 0) do
      post :create, agreement: { dua: fixture_file_upload('../../test/support/agreements/blank.pdf') }
    end

    assert_redirected_to dua_path # agreement_path(assigns(:agreement))
  end

  test "should get sign in for dua" do
    get :dua
    assert_response :success
    assert_template 'dua_sign_in'
  end

  test "should get new dua" do
    login(users(:editor))
    get :dua
    assert_response :success
    assert_template 'dua'
  end

  test "should get submitted dua" do
    login(users(:two))
    get :dua
    assert_response :success
    assert_template 'dua_submitted'
  end

  test "should get resubmit dua" do
    login(users(:admin))
    get :dua
    assert_response :success
    assert_template 'dua_submitted'
  end

  test "should get approved dua" do
    login(users(:valid))
    get :dua
    assert_response :success
    assert_template 'dua_approved'
  end

  test "should show agreement" do
    login(users(:admin))
    get :show, id: @agreement
    assert_response :success
  end

  # test "should get edit" do
  #   get :edit, id: @agreement
  #   assert_response :success
  # end

  test "should update agreement" do
    login(users(:valid))
    patch :update, id: @agreement, agreement: { dua: fixture_file_upload('../../test/support/agreements/blank.pdf') }
    assert_redirected_to dua_path # agreement_path(assigns(:agreement))
  end

  test "should destroy agreement" do
    login(users(:admin))
    assert_difference('Agreement.current.count', -1) do
      delete :destroy, id: @agreement
    end

    assert_redirected_to agreements_path
  end
end

require 'test_helper'

class AgreementsControllerTest < ActionController::TestCase
  setup do
    @agreement = agreements(:one)

  end

  test "should get sign in for daua" do
    get :daua
    assert_response :success
    assert_template 'daua_sign_in'
  end

  test "should get new daua" do
    login(users(:editor))
    get :daua
    assert_response :success
    assert_template 'daua'
  end

  test "should get submitted daua" do
    login(users(:two))
    get :daua
    assert_response :success
    assert_template 'daua_submitted'
  end

  test "should get resubmit daua" do
    login(users(:admin))
    get :daua
    assert_response :success
    assert_template 'daua_submitted'
  end

  test "should get approved daua" do
    login(users(:valid))
    get :daua
    assert_response :success
    assert_template 'daua_approved'
  end

  test "should submit agreement" do
    login(users(:editor))
    assert_difference('Agreement.count') do
      post :submit, agreement: { dua: fixture_file_upload('../../test/support/agreements/blank.pdf') }
    end

    assert_redirected_to daua_path # agreement_path(assigns(:agreement))
  end

  test "should not submit agreement if one already exists" do
    login(users(:valid))
    assert_difference('Agreement.count', 0) do
      post :submit, agreement: { dua: fixture_file_upload('../../test/support/agreements/blank.pdf') }
    end

    assert_redirected_to daua_path # agreement_path(assigns(:agreement))
  end

  test "should resubmit agreement" do
    login(users(:admin))
    patch :resubmit, agreement: { dua: fixture_file_upload('../../test/support/agreements/blank.pdf') }
    assert_redirected_to daua_path # agreement_path(assigns(:agreement))
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

  test "should show agreement" do
    login(users(:admin))
    get :show, id: @agreement
    assert_response :success
  end

  test "should download pdf" do
    login(users(:admin))
    get :download, id: @agreement
    assert_not_nil assigns(:agreement)
    assert_kind_of String, response.body
    assert_equal File.binread( File.join('test', 'support', 'agreements', 'blank.pdf') ), response.body
    assert_response :success
  end

  test "should get review" do
    login(users(:admin))
    get :review, id: @agreement
    assert_response :success
  end

  test "should update agreement and set as approved" do
    login(users(:admin))
    patch :update, id: agreements(:two), agreement: { executed_dua: fixture_file_upload('../../test/support/agreements/blank.pdf'), evidence_of_irb_review: true, status: 'approved' }

    assert_not_nil assigns(:agreement)
    assert_equal true, assigns(:agreement).evidence_of_irb_review
    assert_equal 'approved', assigns(:agreement).status
    assert_equal 'blank.pdf', assigns(:agreement).executed_dua.file.identifier

    assert_redirected_to agreement_path(assigns(:agreement))
  end

  test "should update agreement and ask user to resubmit" do
    login(users(:admin))
    patch :update, id: @agreement, agreement: { status: 'resubmit', comments: 'Please Resubmit' }

    assert_not_nil assigns(:agreement)
    assert_equal 'resubmit', assigns(:agreement).status
    assert_equal 'Please Resubmit', assigns(:agreement).comments

    assert_redirected_to agreement_path(assigns(:agreement))
  end

  test "should not approve agreement without executed dua" do
    login(users(:admin))
    patch :update, id: @agreement, agreement: { executed_dua: '', evidence_of_irb_review: true, status: 'approved' }

    assert_not_nil assigns(:agreement)

    assert assigns(:agreement).errors.size > 0
    assert_equal ["can't be blank"], assigns(:agreement).errors[:executed_dua]

    assert_template 'review'
  end

  test "should not update agreement and ask user to resubmit without comments" do
    login(users(:admin))
    patch :update, id: @agreement, agreement: { status: 'resubmit', comments: '' }

    assert_not_nil assigns(:agreement)

    assert assigns(:agreement).errors.size > 0
    assert_equal ["can't be blank"], assigns(:agreement).errors[:comments]

    assert_template 'review'
  end

  test "should destroy agreement" do
    login(users(:admin))
    assert_difference('Agreement.current.count', -1) do
      delete :destroy, id: @agreement
    end

    assert_redirected_to agreements_path
  end
end

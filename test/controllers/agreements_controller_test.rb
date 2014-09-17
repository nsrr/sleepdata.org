require 'test_helper'

class AgreementsControllerTest < ActionController::TestCase
  setup do
    @agreement = agreements(:one)
  end

  test "should get submissions for valid user" do
    login(users(:valid))
    get :submissions

    assert_not_nil assigns(:agreements)
    assert_response :success
  end

  test "should get step1 when no step is given" do
    login(users(:valid))
    get :step, id: @agreement
    assert_not_nil assigns(:agreement)
    assert_redirected_to step_agreement_path(assigns(:agreement), step: 1)
  end

  test "should get step1 of agreement" do
    login(users(:valid))
    get :step, id: @agreement, step: 1
    assert_not_nil assigns(:agreement)
    assert_template 'wizard/step1'
    assert_response :success
  end

  test "should get step2 of agreement" do
    login(users(:valid))
    get :step, id: @agreement, step: 2
    assert_not_nil assigns(:agreement)
    assert_template 'wizard/step2'
    assert_response :success
  end

  test "should get step3 of agreement" do
    login(users(:valid))
    get :step, id: @agreement, step: 3
    assert_not_nil assigns(:agreement)
    assert_template 'wizard/step3'
    assert_response :success
  end

  test "should get step4 of agreement" do
    login(users(:valid))
    get :step, id: @agreement, step: 4
    assert_not_nil assigns(:agreement)
    assert_template 'wizard/step4'
    assert_response :success
  end


  test "should get step5 of agreement" do
    login(users(:valid))
    get :step, id: @agreement, step: 5
    assert_not_nil assigns(:agreement)
    assert_template 'wizard/step5'
    assert_response :success
  end

  test "should get step6 of agreement" do
    login(users(:valid))
    get :step, id: @agreement, step: 6
    assert_not_nil assigns(:agreement)
    assert_template 'wizard/step6'
    assert_response :success
  end

  test "should get step7 of agreement" do
    login(users(:valid))
    get :step, id: @agreement, step: 7
    assert_not_nil assigns(:agreement)
    assert_template 'wizard/step7'
    assert_response :success
  end

  test "should get step8 of agreement" do
    login(users(:valid))
    get :step, id: @agreement, step: 8
    assert_not_nil assigns(:agreement)
    assert_template 'wizard/step8'
    assert_response :success
  end

  test "should get step9 of agreement" do
    login(users(:valid))
    get :step, id: @agreement, step: 9
    assert_not_nil assigns(:agreement)
    assert_template 'wizard/step9'
    assert_response :success
  end

  test "should get submissions when saving as draft" do
    login(users(:valid))
    patch :update_step, id: @agreement, agreement: { draft_mode: '1' }
    assert_redirected_to submissions_path
  end


  test "should not get submissions for anonymous user" do
    get :submissions
    assert_nil assigns(:agreements)
    assert_redirected_to new_user_session_path
  end

  test "should redirect a user with no submissions to the submissions welcome splash page" do
    login(users(:valid_with_no_submissions))

    get :submissions

    assert_not_nil assigns(:agreements)
    assert_equal 0, assigns(:agreements).count

    assert_redirected_to submissions_welcome_path
  end

  test "should get submissions welcome for valid user" do
    login(users(:valid))
    get :welcome
    assert_response :success
  end

  # Older Agreements

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
    skip
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

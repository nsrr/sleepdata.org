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
    get :step, id: agreements(:step1_saved_as_draft)
    assert_not_nil assigns(:agreement)
    assert_redirected_to step_agreement_path(assigns(:agreement), step: 1)
  end

  test "should get step1 of agreement" do
    login(users(:valid))
    get :step, id: agreements(:step1_saved_as_draft), step: 1
    assert_not_nil assigns(:agreement)
    assert_template 'wizard/step1'
    assert_response :success
  end

  test "should not get step1 for submitted agreement" do
    login(users(:two))
    get :step, id: agreements(:submitted_application), step: 1
    assert_nil assigns(:agreement)
    assert_redirected_to submissions_path
  end

  test "should create step 1 of agreement as individual" do
    login(users(:valid))
    assert_difference('Agreement.count') do
      post :create_step, step: '1', agreement: { current_step: '1', data_user: 'Valid User', data_user_type: 'individual', individual_institution_name: 'Institution', individual_title: 'Title', individual_telephone: '012-123-2345', individual_fax: '123-123-1234', individual_address: "123 Abc Road\nCity, State 12345\nUSA", organization_business_name: '', organization_contact_name: '', organization_contact_title: '', organization_contact_telephone: '', organization_contact_fax: '', organization_contact_email: '', organization_address: '' }
    end

    assert_equal 1, assigns(:step)
    assert_not_nil assigns(:agreement)
    assert_equal 1, assigns(:agreement).current_step

    assert_equal 'individual', assigns(:agreement).data_user_type
    assert_equal 'Institution', assigns(:agreement).individual_institution_name
    assert_equal 'Title', assigns(:agreement).individual_title
    assert_equal '012-123-2345', assigns(:agreement).individual_telephone
    assert_equal '123-123-1234', assigns(:agreement).individual_fax
    assert_equal "123 Abc Road\nCity, State 12345\nUSA", assigns(:agreement).individual_address

    assert_redirected_to step_agreement_path(assigns(:agreement), step: 2)
  end

  test "should create step 1 of agreement as organization" do
    login(users(:valid))
    assert_difference('Agreement.count') do
      post :create_step, step: '1', agreement: { current_step: '1', data_user: 'Valid User', data_user_type: 'individual', individual_institution_name: 'Institution', individual_title: 'Title', individual_telephone: '012-123-2345', individual_fax: '123-123-1234', individual_address: "123 Abc Road\nCity, State 12345\nUSA", organization_business_name: '', organization_contact_name: '', organization_contact_title: '', organization_contact_telephone: '', organization_contact_fax: '', organization_contact_email: '', organization_address: '' }
    end

    assert_equal 1, assigns(:step)
    assert_not_nil assigns(:agreement)
    assert_equal 1, assigns(:agreement).current_step

    assert_equal 'individual', assigns(:agreement).data_user_type
    assert_equal 'Institution', assigns(:agreement).individual_institution_name
    assert_equal 'Title', assigns(:agreement).individual_title
    assert_equal '012-123-2345', assigns(:agreement).individual_telephone
    assert_equal '123-123-1234', assigns(:agreement).individual_fax
    assert_equal "123 Abc Road\nCity, State 12345\nUSA", assigns(:agreement).individual_address

    assert_redirected_to step_agreement_path(assigns(:agreement), step: 2)
  end

  test "should create step 1 of agreement and save draft as individual" do
    login(users(:valid))
    assert_difference('Agreement.count') do
      post :create_step, step: '1', agreement: { draft_mode: '1', current_step: '1', data_user: 'Valid User', data_user_type: 'individual', individual_institution_name: 'Institution', individual_title: '', individual_telephone: '', individual_fax: '', individual_address: "", organization_business_name: '', organization_contact_name: '', organization_contact_title: '', organization_contact_telephone: '', organization_contact_fax: '', organization_contact_email: '', organization_address: '' }
    end

    assert_equal 1, assigns(:step)
    assert_not_nil assigns(:agreement)
    assert_equal 1, assigns(:agreement).current_step
    assert_equal 'individual', assigns(:agreement).data_user_type
    assert_equal 'Institution', assigns(:agreement).individual_institution_name

    assert_redirected_to submissions_path
  end

  test "should create step 1 of agreement and save draft as organization" do
    login(users(:valid))
    assert_difference('Agreement.count') do
      post :create_step, step: '1', agreement: { draft_mode: '1', current_step: '1', data_user: 'Valid User', data_user_type: 'organization', individual_institution_name: '', individual_title: '', individual_telephone: '', individual_fax: '', individual_address: "", organization_business_name: 'The Company', organization_contact_name: '', organization_contact_title: '', organization_contact_telephone: '', organization_contact_fax: '', organization_contact_email: '', organization_address: '' }
    end

    assert_equal 1, assigns(:step)
    assert_not_nil assigns(:agreement)
    assert_equal 1, assigns(:agreement).current_step
    assert_equal 'organization', assigns(:agreement).data_user_type
    assert_equal 'The Company', assigns(:agreement).organization_business_name

    assert_redirected_to submissions_path
  end

  test "should update step 1 of agreement as individual" do
    login(users(:valid))
    patch :update_step, id: agreements(:step1_saved_as_draft), step: '1', agreement: { current_step: '1', data_user: 'Valid User', data_user_type: 'individual', individual_institution_name: 'Institution', individual_title: 'Title', individual_telephone: '012-123-2345', individual_fax: '123-123-1234', individual_address: "123 Abc Road\nCity, State 12345\nUSA", organization_business_name: '', organization_contact_name: '', organization_contact_title: '', organization_contact_telephone: '', organization_contact_fax: '', organization_contact_email: '', organization_address: '' }

    assert_equal 1, assigns(:step)
    assert_not_nil assigns(:agreement)
    assert_equal 1, assigns(:agreement).current_step

    assert_equal 'individual', assigns(:agreement).data_user_type
    assert_equal 'Institution', assigns(:agreement).individual_institution_name
    assert_equal 'Title', assigns(:agreement).individual_title
    assert_equal '012-123-2345', assigns(:agreement).individual_telephone
    assert_equal '123-123-1234', assigns(:agreement).individual_fax
    assert_equal "123 Abc Road\nCity, State 12345\nUSA", assigns(:agreement).individual_address

    assert_redirected_to step_agreement_path(assigns(:agreement), step: 2)
  end

  test "should update step 1 of agreement as organization" do
    login(users(:valid))
    patch :update_step, id: agreements(:step1_saved_as_draft), step: '1', agreement: { current_step: '1', data_user: 'Valid User', data_user_type: 'organization', individual_institution_name: '', individual_title: '', individual_telephone: '', individual_fax: '', individual_address: "", organization_business_name: 'The Company', organization_contact_name: 'The Lawyer', organization_contact_title: 'Mr. Lawyer', organization_contact_telephone: '098-765-4321', organization_contact_fax: '009-876-4321', organization_contact_email: 'lawyer@example.com', organization_address: "Company Name\n123 Company Way\nCityville, Ohmastate, 12345" }

    assert_equal 1, assigns(:step)
    assert_not_nil assigns(:agreement)
    assert_equal 1, assigns(:agreement).current_step

    assert_equal 'The Company', assigns(:agreement).organization_business_name
    assert_equal 'The Lawyer', assigns(:agreement).organization_contact_name
    assert_equal 'Mr. Lawyer', assigns(:agreement).organization_contact_title
    assert_equal '098-765-4321', assigns(:agreement).organization_contact_telephone
    assert_equal '009-876-4321', assigns(:agreement).organization_contact_fax
    assert_equal 'lawyer@example.com', assigns(:agreement).organization_contact_email
    assert_equal "Company Name\n123 Company Way\nCityville, Ohmastate, 12345", assigns(:agreement).organization_address

    assert_redirected_to step_agreement_path(assigns(:agreement), step: 2)
  end

  test "should update step 1 of agreement and save draft as individual" do
    login(users(:valid))
    patch :update_step, id: agreements(:step1_saved_as_draft), step: '1', agreement: { draft_mode: '1', current_step: '1', data_user: 'Valid User', data_user_type: 'individual', individual_institution_name: 'Institution', individual_title: '', individual_telephone: '', individual_fax: '', individual_address: "", organization_business_name: '', organization_contact_name: '', organization_contact_title: '', organization_contact_telephone: '', organization_contact_fax: '', organization_contact_email: '', organization_address: '' }

    assert_equal 1, assigns(:step)
    assert_not_nil assigns(:agreement)
    assert_equal 1, assigns(:agreement).current_step
    assert_equal 'individual', assigns(:agreement).data_user_type
    assert_equal 'Institution', assigns(:agreement).individual_institution_name

    assert_redirected_to submissions_path
  end

  test "should update step 1 of agreement and save draft as organization" do
    login(users(:valid))
    patch :update_step, id: agreements(:step1_saved_as_draft), step: '1', agreement: { draft_mode: '1', current_step: '1', data_user: 'Valid User', data_user_type: 'organization', individual_institution_name: '', individual_title: '', individual_telephone: '', individual_fax: '', individual_address: "", organization_business_name: 'The Company', organization_contact_name: '', organization_contact_title: '', organization_contact_telephone: '', organization_contact_fax: '', organization_contact_email: '', organization_address: '' }

    assert_equal 1, assigns(:step)
    assert_not_nil assigns(:agreement)
    assert_equal 1, assigns(:agreement).current_step
    assert_equal 'organization', assigns(:agreement).data_user_type
    assert_equal 'The Company', assigns(:agreement).organization_business_name

    assert_redirected_to submissions_path
  end

  test "should not update and continue if step 1 is partial as individual" do
    login(users(:valid))
    patch :update_step, id: agreements(:step1_saved_as_draft), step: '1', agreement: { current_step: '1', data_user: 'Valid User', data_user_type: 'individual', individual_institution_name: '', individual_title: '', individual_telephone: '', individual_fax: '', individual_address: '', organization_business_name: '', organization_contact_name: '', organization_contact_title: '', organization_contact_telephone: '', organization_contact_fax: '', organization_contact_email: '', organization_address: '' }

    assert_equal 1, assigns(:step)
    assert_not_nil assigns(:agreement)
    assert_equal 1, assigns(:agreement).current_step
    assert_equal 'individual', assigns(:agreement).data_user_type
    assert assigns(:agreement).errors.size > 0

    assert_equal ["can't be blank"], assigns(:agreement).errors[:individual_institution_name]
    assert_equal ["can't be blank"], assigns(:agreement).errors[:individual_title]
    assert_equal ["can't be blank"], assigns(:agreement).errors[:individual_telephone]
    assert_equal ["can't be blank"], assigns(:agreement).errors[:individual_fax]
    assert_equal ["can't be blank"], assigns(:agreement).errors[:individual_address]

    assert_template 'agreements/wizard/step1'
    assert_response :success
  end

  test "should not update and continue if step1 is partial as organization" do
    login(users(:valid))
    patch :update_step, id: agreements(:step1_saved_as_draft), step: '1', agreement: { current_step: '1', data_user: 'Valid User', data_user_type: 'organization', individual_institution_name: '', individual_title: '', individual_telephone: '', individual_fax: '', individual_address: '', organization_business_name: '', organization_contact_name: '', organization_contact_title: '', organization_contact_telephone: '', organization_contact_fax: '', organization_contact_email: '', organization_address: '' }

    assert_equal 1, assigns(:step)
    assert_not_nil assigns(:agreement)
    assert_equal 1, assigns(:agreement).current_step
    assert_equal 'organization', assigns(:agreement).data_user_type

    assert assigns(:agreement).errors.size > 0
    assert_equal ["can't be blank"], assigns(:agreement).errors[:organization_business_name]
    assert_equal ["can't be blank"], assigns(:agreement).errors[:organization_contact_name]
    assert_equal ["can't be blank"], assigns(:agreement).errors[:organization_contact_title]
    assert_equal ["can't be blank"], assigns(:agreement).errors[:organization_contact_telephone]
    assert_equal ["can't be blank"], assigns(:agreement).errors[:organization_contact_fax]
    assert_equal ["can't be blank"], assigns(:agreement).errors[:organization_contact_email]
    assert_equal ["can't be blank"], assigns(:agreement).errors[:organization_address]

    assert_template 'agreements/wizard/step1'
    assert_response :success
  end

  test "should get step2 of agreement" do
    login(users(:valid))
    get :step, id: agreements(:step1_saved_as_draft), step: 2
    assert_not_nil assigns(:agreement)
    assert_template 'wizard/step2'
    assert_response :success
  end

  test "should update step 2 of agreement and continue" do
    login(users(:valid))
    assert_difference('Request.count') do
      patch :update_step, id: agreements(:step1_saved_as_draft), step: '2', agreement: { current_step: '2', specific_purpose: 'My Specific Purpose', dataset_ids: [0, ActiveRecord::FixtureSet.identify(:public)] }
    end

    assert_equal 2, assigns(:step)
    assert_not_nil assigns(:agreement)
    assert_equal 2, assigns(:agreement).current_step
    assert_equal 'My Specific Purpose', assigns(:agreement).specific_purpose
    assert_equal [datasets(:public).id], assigns(:agreement).datasets.pluck(:id)

    assert_redirected_to step_agreement_path(assigns(:agreement), step: 3)
  end

  test "should update step 2 of agreement save draft" do
    login(users(:valid))
    patch :update_step, id: agreements(:step1_saved_as_draft), step: '2', agreement: { draft_mode: '1', current_step: '2', specific_purpose: '', dataset_ids: [0] }

    assert_equal 2, assigns(:step)
    assert_not_nil assigns(:agreement)
    assert_equal 2, assigns(:agreement).current_step
    assert_equal '', assigns(:agreement).specific_purpose
    assert_equal [], assigns(:agreement).datasets.pluck(:id)

    assert_redirected_to submissions_path
  end

  test "should get step3 of agreement" do
    login(users(:valid))
    get :step, id: agreements(:step1_saved_as_draft), step: 3
    assert_not_nil assigns(:agreement)
    assert_template 'wizard/step3'
    assert_response :success
  end

  test "should get step4 of agreement" do
    login(users(:valid))
    get :step, id: agreements(:step1_saved_as_draft), step: 4
    assert_not_nil assigns(:agreement)
    assert_template 'wizard/step4'
    assert_response :success
  end

  test "should get step5 of agreement" do
    login(users(:valid))
    get :step, id: agreements(:step1_saved_as_draft), step: 5
    assert_not_nil assigns(:agreement)
    assert_template 'wizard/step5'
    assert_response :success
  end

  test "should get step6 of agreement" do
    login(users(:valid))
    get :step, id: agreements(:step1_saved_as_draft), step: 6
    assert_not_nil assigns(:agreement)
    assert_template 'wizard/step6'
    assert_response :success
  end

  test "should get step7 of agreement" do
    login(users(:valid))
    get :step, id: agreements(:step1_saved_as_draft), step: 7
    assert_not_nil assigns(:agreement)
    assert_template 'wizard/step7'
    assert_response :success
  end

  test "should get step8 of agreement" do
    login(users(:valid))
    get :step, id: agreements(:step1_saved_as_draft), step: 8
    assert_not_nil assigns(:agreement)
    assert_template 'wizard/step8'
    assert_response :success
  end

  test "should get submissions when saving as draft" do
    login(users(:valid))
    patch :update_step, id: @agreement, agreement: { draft_mode: '1' }
    assert_redirected_to submissions_path
  end

  test "should get proof when saving a filled out application" do
    login(users(:valid))
    patch :update_step, id: agreements(:filled_out_application_with_attached_irb_file), step: '7', agreement: { current_step: '7' }

    assert_not_nil assigns(:agreement)
    assert_redirected_to proof_agreement_path(assigns(:agreement))
  end

  test "should submit final submission for filled out application" do
    login(users(:valid))
    patch :final_submission, id: agreements(:filled_out_application_with_attached_irb_file)

    assert_not_nil assigns(:agreement)
    assert_equal [], assigns(:agreement).errors.full_messages
    assert_equal 'submitted', assigns(:agreement).status
    assert_equal Date.today, assigns(:agreement).submitted_at.to_date

    assert_redirected_to complete_agreement_path(assigns(:agreement))
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
    skip
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

# Note: There currently is no dedicated downloads_controller.rb, however handling
# file downloads from datasets combined with agreements needs to be separated from
# simple dataset updates, and makes more sense as it's own controller.

require 'test_helper'

class DownloadsControllerTest < ActionController::TestCase
  setup do
    @controller = DatasetsController.new # Will get removed when downloads_controller.rb is added
    @dataset = datasets(:public)
  end

  test 'should access private files on public documentation dataset with approved agreement' do
    login(users(:has_approved_agreement_for_a_b_not_c))
    get :files, params: { id: datasets(:public_documentation), path: 'ACCESS_REQUIRED.txt', format: 'html' }
    assert_not_nil assigns(:dataset)
    assert_not_nil response
    assert_kind_of String, response.body
    assert_equal File.read(assigns(:dataset).find_file('ACCESS_REQUIRED.txt')), response.body
  end

  test 'should access private files on private documentation dataset with approved agreement' do
    login(users(:has_approved_agreement_for_a_b_not_c))
    get :files, params: { id: datasets(:private_documentation), path: 'ACCESS_REQUIRED.txt', format: 'html' }
    assert_not_nil assigns(:dataset)
    assert_not_nil response
    assert_kind_of String, response.body
    assert_equal File.read(assigns(:dataset).find_file('ACCESS_REQUIRED.txt')), response.body
  end

  test 'should not access private files on no access dataset without approved agreement' do
    login(users(:has_approved_agreement_for_a_b_not_c))
    get :files, params: { id: datasets(:public_documentation_no_access), path: 'ACCESS_REQUIRED.txt', format: 'html' }
    assert_not_nil assigns(:dataset)
    assert_redirected_to files_dataset_path(assigns(:dataset))
  end

  test 'should not access private files on public documentation dataset with approved but expired agreement' do
    login(users(:has_approved_but_expired_agreement_for_a_b_not_c))
    get :files, params: { id: datasets(:public_documentation), path: 'ACCESS_REQUIRED.txt', format: 'html' }
    assert_not_nil assigns(:dataset)
    assert_redirected_to files_dataset_path(assigns(:dataset))
  end

  test 'should not access private files on private documentation dataset with approved but expired agreement' do
    login(users(:has_approved_but_expired_agreement_for_a_b_not_c))
    get :files, params: { id: datasets(:private_documentation), path: 'ACCESS_REQUIRED.txt', format: 'html' }
    assert_nil assigns(:dataset)
    assert_redirected_to datasets_path
  end

  test 'should not access private files on no access dataset without approved but expired agreement' do
    login(users(:has_approved_but_expired_agreement_for_a_b_not_c))
    get :files, params: { id: datasets(:public_documentation_no_access), path: 'ACCESS_REQUIRED.txt', format: 'html' }
    assert_not_nil assigns(:dataset)
    assert_redirected_to files_dataset_path(assigns(:dataset))
  end

  test 'should not access private files on public documentation dataset with submitted agreement' do
    login(users(:has_submitted_agreement_for_a_b_not_c))
    get :files, params: { id: datasets(:public_documentation), path: 'ACCESS_REQUIRED.txt', format: 'html' }
    assert_not_nil assigns(:dataset)
    assert_redirected_to files_dataset_path(assigns(:dataset))
  end

  test 'should not access private files on private documentation dataset with submitted agreement' do
    login(users(:has_submitted_agreement_for_a_b_not_c))
    get :files, params: { id: datasets(:private_documentation), path: 'ACCESS_REQUIRED.txt', format: 'html' }
    assert_nil assigns(:dataset)
    assert_redirected_to datasets_path
  end

  test 'should not access private files on no access dataset without submitted agreement' do
    login(users(:has_submitted_agreement_for_a_b_not_c))
    get :files, params: { id: datasets(:public_documentation_no_access), path: 'ACCESS_REQUIRED.txt', format: 'html' }
    assert_not_nil assigns(:dataset)
    assert_redirected_to files_dataset_path(assigns(:dataset))
  end

  test 'should not access private files on public documentation dataset with started agreement' do
    login(users(:has_started_agreement_for_a_b_not_c))
    get :files, params: { id: datasets(:public_documentation), path: 'ACCESS_REQUIRED.txt', format: 'html' }
    assert_not_nil assigns(:dataset)
    assert_redirected_to files_dataset_path(assigns(:dataset))
  end

  test 'should not access private files on private documentation dataset with started agreement' do
    login(users(:has_started_agreement_for_a_b_not_c))
    get :files, params: { id: datasets(:private_documentation), path: 'ACCESS_REQUIRED.txt', format: 'html' }
    assert_nil assigns(:dataset)
    assert_redirected_to datasets_path
  end

  test 'should not access private files on no access dataset without started agreement' do
    login(users(:has_started_agreement_for_a_b_not_c))
    get :files, params: { id: datasets(:public_documentation_no_access), path: 'ACCESS_REQUIRED.txt', format: 'html' }
    assert_not_nil assigns(:dataset)
    assert_redirected_to files_dataset_path(assigns(:dataset))
  end

  test 'should not access private files on public documentation dataset with resubmit agreement' do
    login(users(:has_resubmit_agreement_for_a_b_not_c))
    get :files, params: { id: datasets(:public_documentation), path: 'ACCESS_REQUIRED.txt', format: 'html' }
    assert_not_nil assigns(:dataset)
    assert_redirected_to files_dataset_path(assigns(:dataset))
  end

  test 'should not access private files on private documentation dataset with resubmit agreement' do
    login(users(:has_resubmit_agreement_for_a_b_not_c))
    get :files, params: { id: datasets(:private_documentation), path: 'ACCESS_REQUIRED.txt', format: 'html' }
    assert_nil assigns(:dataset)
    assert_redirected_to datasets_path
  end

  test 'should not access private files on no access dataset without resubmit agreement' do
    login(users(:has_resubmit_agreement_for_a_b_not_c))
    get :files, params: { id: datasets(:public_documentation_no_access), path: 'ACCESS_REQUIRED.txt', format: 'html' }
    assert_not_nil assigns(:dataset)
    assert_redirected_to files_dataset_path(assigns(:dataset))
  end

  test 'should not access private files on public documentation dataset with approved but deleted agreement' do
    login(users(:has_approved_but_deleted_agreement_for_a_b_not_c))
    get :files, params: { id: datasets(:public_documentation), path: 'ACCESS_REQUIRED.txt', format: 'html' }
    assert_not_nil assigns(:dataset)
    assert_redirected_to files_dataset_path(assigns(:dataset))
  end

  test 'should not access private files on private documentation dataset with approved but deleted agreement' do
    login(users(:has_approved_but_deleted_agreement_for_a_b_not_c))
    get :files, params: { id: datasets(:private_documentation), path: 'ACCESS_REQUIRED.txt', format: 'html' }
    assert_nil assigns(:dataset)
    assert_redirected_to datasets_path
  end

  test 'should not access private files on no access dataset without approved but deleted agreement' do
    login(users(:has_approved_but_deleted_agreement_for_a_b_not_c))
    get :files, params: { id: datasets(:public_documentation_no_access), path: 'ACCESS_REQUIRED.txt', format: 'html' }
    assert_not_nil assigns(:dataset)
    assert_redirected_to files_dataset_path(assigns(:dataset))
  end

  test 'should not access private files on public documentation dataset without any agreement' do
    login(users(:has_no_agreement_for_a_b_not_c))
    get :files, params: { id: datasets(:public_documentation), path: 'ACCESS_REQUIRED.txt', format: 'html' }
    assert_not_nil assigns(:dataset)
    assert_redirected_to files_dataset_path(assigns(:dataset))
  end

  test 'should not access private files on private documentation dataset without any agreement' do
    login(users(:has_no_agreement_for_a_b_not_c))
    get :files, params: { id: datasets(:private_documentation), path: 'ACCESS_REQUIRED.txt', format: 'html' }
    assert_nil assigns(:dataset)
    assert_redirected_to datasets_path
  end

  test 'should not access private files on no access dataset without any agreement' do
    login(users(:has_no_agreement_for_a_b_not_c))
    get :files, params: { id: datasets(:public_documentation_no_access), path: 'ACCESS_REQUIRED.txt', format: 'html' }
    assert_not_nil assigns(:dataset)
    assert_redirected_to files_dataset_path(assigns(:dataset))
  end

  test 'should list private files on public documentation dataset as anonymous user' do
    get :files, params: { id: datasets(:public_documentation), format: 'html' }
    assert_not_nil assigns(:dataset)
    assert_template partial: '_folder'
    assert_response :success
  end

  test 'should not list private files on private documentation dataset as anonymous user' do
    get :files, params: { id: datasets(:private_documentation), format: 'html' }
    assert_nil assigns(:dataset)
    assert_redirected_to datasets_path
  end

  test 'should list private files on no access dataset as anonymous user' do
    get :files, params: { id: datasets(:public_documentation_no_access), format: 'html' }
    assert_not_nil assigns(:dataset)
    assert_template partial: '_folder'
    assert_response :success
  end
end

# frozen_string_literal: true

# Note: There currently is no dedicated documentation_controller.rb, however handling
# file downloads from datasets combined with agreements needs to be separated from
# simple dataset updates, and makes more sense as it's own controller.

require 'test_helper'

class DocumentationControllerTest < ActionController::TestCase
  setup do
    @controller = DatasetsController.new # Will get removed when documentation_controller.rb is added
    @dataset = datasets(:public)
  end

  test "should view documentation on public documentation dataset with approved agreement" do
    login(users(:has_approved_agreement_for_a_b_not_c))
    get :pages, id: datasets(:public_documentation), path: 'PUBLICLY_VIEWABLE.md'
    assert_not_nil assigns(:dataset)
    assert_response :success
  end

  test "should view documentation on private documentation dataset with approved agreement" do
    login(users(:has_approved_agreement_for_a_b_not_c))
    get :pages, id: datasets(:private_documentation), path: 'ACCESS_REQUIRED.md'
    assert_not_nil assigns(:dataset)
    assert_response :success
  end

  test "should view documentation on no access dataset without approved agreement" do
    login(users(:has_approved_agreement_for_a_b_not_c))
    get :pages, id: datasets(:public_documentation_no_access), path: 'PUBLICLY_VIEWABLE.md'
    assert_not_nil assigns(:dataset)
    assert_response :success
  end

  test "should view documentation on public documentation dataset with approved but expired agreement" do
    login(users(:has_approved_but_expired_agreement_for_a_b_not_c))
    get :pages, id: datasets(:public_documentation), path: 'PUBLICLY_VIEWABLE.md'
    assert_not_nil assigns(:dataset)
    assert_response :success
  end

  test "should not view documentation on private documentation dataset with approved but expired agreement" do
    login(users(:has_approved_but_expired_agreement_for_a_b_not_c))
    get :pages, id: datasets(:private_documentation), path: 'ACCESS_REQUIRED.md'
    assert_nil assigns(:dataset)
    assert_redirected_to datasets_path
  end

  test "should view documentation on no access dataset without approved but expired agreement" do
    login(users(:has_approved_but_expired_agreement_for_a_b_not_c))
    get :pages, id: datasets(:public_documentation_no_access), path: 'PUBLICLY_VIEWABLE.md'
    assert_not_nil assigns(:dataset)
    assert_response :success
  end

  test "should view documentation on public documentation dataset with submitted agreement" do
    login(users(:has_submitted_agreement_for_a_b_not_c))
    get :pages, id: datasets(:public_documentation), path: 'PUBLICLY_VIEWABLE.md'
    assert_not_nil assigns(:dataset)
    assert_response :success
  end

  test "should not view documentation on private documentation dataset with submitted agreement" do
    login(users(:has_submitted_agreement_for_a_b_not_c))
    get :pages, id: datasets(:private_documentation), path: 'ACCESS_REQUIRED.md'
    assert_nil assigns(:dataset)
    assert_redirected_to datasets_path
  end

  test "should view documentation on no access dataset without submitted agreement" do
    login(users(:has_submitted_agreement_for_a_b_not_c))
    get :pages, id: datasets(:public_documentation_no_access), path: 'PUBLICLY_VIEWABLE.md'
    assert_not_nil assigns(:dataset)
    assert_response :success
  end

  test "should view documentation on public documentation dataset with started agreement" do
    login(users(:has_started_agreement_for_a_b_not_c))
    get :pages, id: datasets(:public_documentation), path: 'PUBLICLY_VIEWABLE.md'
    assert_not_nil assigns(:dataset)
    assert_response :success
  end

  test "should not view documentation on private documentation dataset with started agreement" do
    login(users(:has_started_agreement_for_a_b_not_c))
    get :pages, id: datasets(:private_documentation), path: 'ACCESS_REQUIRED.md'
    assert_nil assigns(:dataset)
    assert_redirected_to datasets_path
  end

  test "should view documentation on no access dataset without started agreement" do
    login(users(:has_started_agreement_for_a_b_not_c))
    get :pages, id: datasets(:public_documentation_no_access), path: 'PUBLICLY_VIEWABLE.md'
    assert_not_nil assigns(:dataset)
    assert_response :success
  end

  test "should view documentation on public documentation dataset with resubmit agreement" do
    login(users(:has_resubmit_agreement_for_a_b_not_c))
    get :pages, id: datasets(:public_documentation), path: 'PUBLICLY_VIEWABLE.md'
    assert_not_nil assigns(:dataset)
    assert_response :success
  end

  test "should not view documentation on private documentation dataset with resubmit agreement" do
    login(users(:has_resubmit_agreement_for_a_b_not_c))
    get :pages, id: datasets(:private_documentation), path: 'ACCESS_REQUIRED.md'
    assert_nil assigns(:dataset)
    assert_redirected_to datasets_path
  end

  test "should view documentation on no access dataset without resubmit agreement" do
    login(users(:has_resubmit_agreement_for_a_b_not_c))
    get :pages, id: datasets(:public_documentation_no_access), path: 'PUBLICLY_VIEWABLE.md'
    assert_not_nil assigns(:dataset)
    assert_response :success
  end

  test "should view documentation on public documentation dataset with approved but deleted agreement" do
    login(users(:has_approved_but_deleted_agreement_for_a_b_not_c))
    get :pages, id: datasets(:public_documentation), path: 'PUBLICLY_VIEWABLE.md'
    assert_not_nil assigns(:dataset)
    assert_response :success
  end

  test "should not view documentation on private documentation dataset with approved but deleted agreement" do
    login(users(:has_approved_but_deleted_agreement_for_a_b_not_c))
    get :pages, id: datasets(:private_documentation), path: 'ACCESS_REQUIRED.md'
    assert_nil assigns(:dataset)
    assert_redirected_to datasets_path
  end

  test "should view documentation on no access dataset without approved but deleted agreement" do
    login(users(:has_approved_but_deleted_agreement_for_a_b_not_c))
    get :pages, id: datasets(:public_documentation_no_access), path: 'PUBLICLY_VIEWABLE.md'
    assert_not_nil assigns(:dataset)
    assert_response :success
  end

  test "should view documentation on public documentation dataset without any agreement" do
    login(users(:has_no_agreement_for_a_b_not_c))
    get :pages, id: datasets(:public_documentation), path: 'PUBLICLY_VIEWABLE.md'
    assert_not_nil assigns(:dataset)
    assert_response :success
  end

  test "should not view documentation on private documentation dataset without any agreement" do
    login(users(:has_no_agreement_for_a_b_not_c))
    get :pages, id: datasets(:private_documentation), path: 'ACCESS_REQUIRED.md'
    assert_nil assigns(:dataset)
    assert_redirected_to datasets_path
  end

  test "should view documentation on no access dataset without any agreement" do
    login(users(:has_no_agreement_for_a_b_not_c))
    get :pages, id: datasets(:public_documentation_no_access), path: 'PUBLICLY_VIEWABLE.md'
    assert_not_nil assigns(:dataset)
    assert_response :success
  end

  test "should view documentation on public documentation dataset as anonymous user" do
    get :pages, id: datasets(:public_documentation), path: 'PUBLICLY_VIEWABLE.md'
    assert_not_nil assigns(:dataset)
    assert_response :success
  end

  test "should not view documentation on private documentation dataset as anonymous user" do
    get :pages, id: datasets(:private_documentation), path: 'ACCESS_REQUIRED.md'
    assert_nil assigns(:dataset)
    assert_redirected_to datasets_path
  end

  test "should view documentation on no access dataset as anonymous user" do
    get :pages, id: datasets(:public_documentation_no_access), path: 'PUBLICLY_VIEWABLE.md'
    assert_not_nil assigns(:dataset)
    assert_response :success
  end

end

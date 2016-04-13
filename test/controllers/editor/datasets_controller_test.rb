# frozen_string_literal: true

require 'test_helper'

# Tests to assure that dataset editors can modify datasets.
class Editor::DatasetsControllerTest < ActionController::TestCase
  setup do
    @dataset = datasets(:public)
  end

  test 'should get audits' do
    login(users(:editor))
    get :audits, id: @dataset
    assert_not_nil assigns(:audits)
    assert_response :success
  end

  test 'should create access role to dataset' do
    login(users(:editor))
    assert_difference('DatasetUser.count') do
      post :create_access, id: @dataset, user_email: "#{users(:aug).name} [#{users(:aug).email}]", role: 'editor'
    end
    assert_not_nil assigns(:dataset_user)
    assert_equal 'editor', assigns(:dataset_user).role
    assert_equal users(:aug), assigns(:dataset_user).user
    assert_redirected_to collaborators_dataset_path(assigns(:dataset), dataset_user_id: assigns(:dataset_user).id)
  end

  test 'should find existing access when creating access request to dataset' do
    login(users(:editor))
    assert_difference('DatasetUser.count', 0) do
      post :create_access, id: @dataset, user_email: "#{users(:two).name} [#{users(:two).email}]"
    end
    assert_not_nil assigns(:dataset_user)
    assert_equal nil, assigns(:dataset_user).approved
    assert_equal false, assigns(:dataset_user).editor
    assert_equal users(:two), assigns(:dataset_user).user
    assert_redirected_to collaborators_dataset_path(assigns(:dataset), dataset_user_id: assigns(:dataset_user).id)
  end

  test 'should show collaborators to editor' do
    login(users(:editor))
    get :collaborators, id: @dataset
    assert_response :success
  end

  test 'should reset index as editor' do
    login(users(:editor_mixed))
    post :reset_index, id: datasets(:mixed), path: nil
    assert_redirected_to files_dataset_path(assigns(:dataset), path: '')
  end

  test 'should not reset index as viewer' do
    login(users(:valid))
    post :reset_index, id: datasets(:mixed), path: nil
    assert_redirected_to datasets_path
  end

  test 'should not reset index as anonymous' do
    post :reset_index, id: datasets(:mixed), path: nil
    assert_redirected_to new_user_session_path
  end

  test 'should set file as public as editor' do
    login(users(:editor_mixed))
    assert_difference('DatasetFile.where(publicly_available: true).count') do
      post :set_public_file, id: datasets(:mixed), path: 'NOT_PUBLIC_YET.txt', public: '1'
    end
    assert_redirected_to files_dataset_path(assigns(:dataset), path: '')
  end

  test 'should set file as private as editor' do
    login(users(:editor_mixed))
    assert_difference('DatasetFile.where(publicly_available: true).count', -1) do
      post :set_public_file, id: datasets(:mixed), path: dataset_files(:mixed_public_file_txt).full_path, public: '0'
    end
    assert_redirected_to files_dataset_path(assigns(:dataset), path: '')
  end

  test 'should set file in subfolder as public as editor' do
    login(users(:editor_mixed))
    assert_difference('DatasetFile.where(publicly_available: true).count') do
      post :set_public_file, id: datasets(:mixed), path: 'subfolder/IN_SUBFOLDER_NOT_PUBLIC_YET.txt', public: '1'
    end
    assert_redirected_to files_dataset_path(assigns(:dataset), path: 'subfolder')
  end

  test 'should set file in subfolder as private as editor' do
    login(users(:editor_mixed))
    assert_difference('DatasetFile.where(publicly_available: true).count', -1) do
      post :set_public_file, id: datasets(:mixed), path: 'subfolder/IN_SUBFOLDER_PUBLIC_FILE.txt', public: '0'
    end
    assert_redirected_to files_dataset_path(assigns(:dataset), path: 'subfolder')
  end

  test 'should not set file as public as viewer' do
    login(users(:valid))
    assert_difference('DatasetFile.where(publicly_available: true).count', 0) do
      post :set_public_file, id: datasets(:mixed), path: 'NOT_PUBLIC_YET.txt', public: '1'
    end
    assert_redirected_to datasets_path
  end

  test 'should not set file as public as anonymous' do
    assert_difference('DatasetFile.where(publicly_available: true).count', 0) do
      post :set_public_file, id: datasets(:mixed), path: 'NOT_PUBLIC_YET.txt', public: '1'
    end
    assert_redirected_to new_user_session_path
  end

  test 'should get sync' do
    login(users(:editor))
    get :sync, id: @dataset
    assert_response :success
  end

  test 'should get edit' do
    login(users(:editor))
    get :edit, id: @dataset
    assert_response :success
  end

  test 'should update dataset' do
    login(users(:editor))
    patch :update, id: @dataset, dataset: { name: 'We Care Name Updated', description: @dataset.description, public: @dataset.public, slug: @dataset.slug }
    assert_equal assigns(:dataset).name, 'We Care Name Updated'
    assert_redirected_to dataset_path(assigns(:dataset))
  end

  test 'should not update dataset with blank name' do
    login(users(:editor))
    patch :update, id: @dataset, dataset: { name: '', description: @dataset.description, public: @dataset.public, slug: @dataset.slug }
    assert assigns(:dataset).errors.size > 0
    assert_equal ["can't be blank"], assigns(:dataset).errors[:name]
    assert_template 'edit'
    assert_response :success
  end

  test 'should not update dataset with existing slug' do
    login(users(:editor))
    patch :update, id: @dataset, dataset: { name: '', description: @dataset.description, public: @dataset.public, slug: 'private' }
    assert assigns(:dataset).errors.size > 0
    assert_equal ['has already been taken'], assigns(:dataset).errors[:slug]
    assert_template 'edit'
    assert_response :success
  end
end

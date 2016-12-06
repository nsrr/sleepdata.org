# frozen_string_literal: true

require 'test_helper'

# Tests to assure that admins can create and delete datasets.
class Admin::DatasetsControllerTest < ActionController::TestCase
  setup do
    @dataset = datasets(:public)
    @admin = users(:admin)
  end

  def dataset_params
    {
      name: 'New Dataset',
      description: @dataset.description,
      logo: fixture_file_upload('../../test/support/datasets/wecare/images/rails.png'),
      public: true,
      slug: 'new-dataset',
      release_date: '2014-06-23'
    }
  end

  test 'should get new' do
    login(@admin)
    get :new
    assert_response :success
  end

  test 'should create dataset' do
    login(@admin)
    assert_difference('Dataset.count') do
      post :create, params: { dataset: dataset_params }
    end
    assert_redirected_to dataset_path(assigns(:dataset))
  end

  test 'should not create dataset as anonymous user' do
    assert_difference('Dataset.count', 0) do
      post :create, params: { dataset: dataset_params }
    end
    assert_redirected_to new_user_session_path
  end

  test 'should not create dataset as regular user' do
    login(users(:valid))
    assert_difference('Dataset.count', 0) do
      post :create, params: { dataset: dataset_params }
    end
    assert_redirected_to root_path
  end

  test 'should not create dataset with blank name' do
    login(@admin)
    assert_difference('Dataset.count', 0) do
      post :create, params: { dataset: dataset_params.merge(name: '') }
    end
    assert_equal ["can't be blank"], assigns(:dataset).errors[:name]
    assert_template 'new'
  end

  test 'should not create dataset existing slug' do
    login(@admin)
    assert_difference('Dataset.count', 0) do
      post :create, params: { dataset: dataset_params.merge(slug: 'wecare') }
    end
    assert_equal ['has already been taken'], assigns(:dataset).errors[:slug]
    assert_template 'new'
  end

  test 'should destroy dataset' do
    login(@admin)
    assert_difference('Dataset.current.count', -1) do
      delete :destroy, params: { id: @dataset }
    end
    assert_redirected_to datasets_path
  end
end

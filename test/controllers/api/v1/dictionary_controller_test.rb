require 'test_helper'

class Api::V1::DictionaryControllerTest < ActionController::TestCase
  test 'should get success if dataset csv is uploaded' do
    post :upload_dataset_csv, dataset: datasets(:public), auth_token: users(:editor).id_and_auth_token, file: fixture_file_upload('../../test/support/datasets/wecare/images/rails.png')

    assert_not_nil response
    assert_equal '{"upload":"success"}', response.body
    assert_response :success
  end

  test 'should get failed if dataset csv does not exist after upload' do
    post :upload_dataset_csv, dataset: datasets(:public), auth_token: users(:editor).id_and_auth_token, file: ''

    assert_not_nil response
    assert_equal '{"upload":"failed"}', response.body
    assert_response :success
  end
end

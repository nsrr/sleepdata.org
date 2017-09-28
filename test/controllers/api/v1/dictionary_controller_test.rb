# frozen_string_literal: true

require "test_helper"

class Api::V1::DictionaryControllerTest < ActionController::TestCase
  test "should get success if file is uploaded" do
    post :upload_file, params: {
      dataset: datasets(:released).to_param,
      auth_token: users(:editor).id_and_auth_token,
      file: fixture_file_upload("../../test/support/datasets/wecare/images/rails.png"),
      folder: "datasets"
    }
    assert_not_nil response
    assert_equal "{\"upload\":\"success\"}", response.body
    assert_response :success
  end

  test "should get failed if file does not exist after upload" do
    post :upload_file, params: {
      dataset: datasets(:released).to_param,
      auth_token: users(:editor).id_and_auth_token,
      file: ""
    }
    assert_not_nil response
    assert_equal "{\"upload\":\"failed\"}", response.body
    assert_response :success
  end
end

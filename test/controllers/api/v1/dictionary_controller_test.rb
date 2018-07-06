# frozen_string_literal: true

require "test_helper"

# Test to check that dataset files can be uploaded.
class Api::V1::DictionaryControllerTest < ActionDispatch::IntegrationTest
  test "should get success if file is uploaded" do
    post api_v1_dictionary_upload_file_url, params: {
      dataset: datasets(:released).to_param,
      auth_token: users(:editor).id_and_auth_token,
      file: fixture_file_upload("../../test/support/images/rails.png"),
      folder: "datasets"
    }
    assert_equal "{\"upload\":\"success\"}", response.body
    assert_response :success
  end

  test "should get failed if file does not exist after upload" do
    post api_v1_dictionary_upload_file_url, params: {
      dataset: datasets(:released).to_param,
      auth_token: users(:editor).id_and_auth_token,
      file: ""
    }
    assert_equal "{\"upload\":\"failed\"}", response.body
    assert_response :success
  end
end

# frozen_string_literal: true

require "test_helper"

# Tests to assure that users can view list of available datasets and files.
class Api::V1::DatasetsControllerTest < ActionController::TestCase
  setup do
    @dataset = datasets(:released)
  end

  test "should get index" do
    get :index, format: "json"
    assert_response :success
  end

  test "should get show" do
    get :show, params: { id: @dataset }, format: "json"
    assert_response :success
  end

  test "should get files for single file using auth token" do
    get :files, params: {
      id: @dataset, path: "subfolder/1.txt", auth_token: users(:valid).id_and_auth_token
    }, format: "json"
    manifest = JSON.parse(response.body)
    assert_equal 1, manifest.size
    assert_equal "wecare", manifest[0]["dataset"]
    assert_equal "subfolder/1.txt", manifest[0]["full_path"]
    assert_equal "subfolder/", manifest[0]["folder"]
    assert_equal "1.txt", manifest[0]["file_name"]
    assert_equal true, manifest[0]["is_file"]
    assert_equal 6, manifest[0]["file_size"]
    assert_equal "39061daa34ca3de20df03a88c52530ea", manifest[0]["file_checksum_md5"]
    assert_equal false, manifest[0]["archived"]
    assert_response :success
  end

  test "should get files folder using auth token" do
    get :files, params: {
      id: @dataset, path: "subfolder", auth_token: users(:valid).id_and_auth_token
    }, format: "json"
    manifest = JSON.parse(response.body)
    assert_equal 3, manifest.size
    assert_equal "wecare", manifest[0]["dataset"]
    assert_equal "subfolder/another_folder", manifest[0]["full_path"]
    assert_equal "subfolder/", manifest[0]["folder"]
    assert_equal "another_folder", manifest[0]["file_name"]
    assert_equal false, manifest[0]["is_file"]
    assert_equal 102, manifest[0]["file_size"]
    assert_nil manifest[0]["file_checksum_md5"]
    assert_equal false, manifest[0]["archived"]
    assert_equal "wecare", manifest[1]["dataset"]
    assert_equal "subfolder/1.txt", manifest[1]["full_path"]
    assert_equal "subfolder/", manifest[1]["folder"]
    assert_equal "1.txt", manifest[1]["file_name"]
    assert_equal true, manifest[1]["is_file"]
    assert_equal 6, manifest[1]["file_size"]
    assert_equal "39061daa34ca3de20df03a88c52530ea", manifest[1]["file_checksum_md5"]
    assert_equal false, manifest[1]["archived"]
    assert_equal "wecare", manifest[2]["dataset"]
    assert_equal "subfolder/2.txt", manifest[2]["full_path"]
    assert_equal "subfolder/", manifest[2]["folder"]
    assert_equal "2.txt", manifest[2]["file_name"]
    assert_equal true, manifest[2]["is_file"]
    assert_equal 6, manifest[2]["file_size"]
    assert_equal "85c8f17e86771eb8480a44349e13127b", manifest[2]["file_checksum_md5"]
    assert_equal false, manifest[2]["archived"]
    assert_response :success
  end

  test "should get files with blank path using auth token" do
    get :files, params: {
      id: @dataset, path: "", auth_token: users(:valid).id_and_auth_token
    }, format: "json"
    manifest = JSON.parse(response.body)
    assert_equal 3, manifest.size
    assert_equal "wecare", manifest[0]["dataset"]
    assert_equal "datasets", manifest[0]["full_path"]
    assert_equal "", manifest[0]["folder"]
    assert_equal "datasets", manifest[0]["file_name"]
    assert_equal false, manifest[0]["is_file"]
    assert_equal 102, manifest[0]["file_size"]
    assert_nil manifest[0]["file_checksum_md5"]
    assert_equal false, manifest[0]["archived"]
    assert_equal "wecare", manifest[1]["dataset"]
    assert_equal "subfolder", manifest[1]["full_path"]
    assert_equal "", manifest[1]["folder"]
    assert_equal "subfolder", manifest[1]["file_name"]
    assert_equal false, manifest[1]["is_file"]
    assert_equal 204, manifest[1]["file_size"]
    assert_nil manifest[1]["file_checksum_md5"]
    assert_equal false, manifest[1]["archived"]
    assert_equal "wecare", manifest[2]["dataset"]
    assert_equal "DOWNLOAD_ME.txt", manifest[2]["full_path"]
    assert_equal "", manifest[2]["folder"]
    assert_equal "DOWNLOAD_ME.txt", manifest[2]["file_name"]
    assert_equal true, manifest[2]["is_file"]
    assert_equal 16, manifest[2]["file_size"]
    assert_equal "be3aad0b46648b4867534a1b10ec6ed1", manifest[2]["file_checksum_md5"]
    assert_equal false, manifest[2]["archived"]
    assert_response :success
  end

  test "should get files with nil path using auth token" do
    get :files, params: {
      id: @dataset, auth_token: users(:valid).id_and_auth_token
    }, format: "json"
    manifest = JSON.parse(response.body)
    assert_equal 3, manifest.size
    assert_equal "wecare", manifest[0]["dataset"]
    assert_equal "datasets", manifest[0]["full_path"]
    assert_equal "", manifest[0]["folder"]
    assert_equal "datasets", manifest[0]["file_name"]
    assert_equal false, manifest[0]["is_file"]
    assert_equal 102, manifest[0]["file_size"]
    assert_nil manifest[0]["file_checksum_md5"]
    assert_equal false, manifest[0]["archived"]
    assert_equal "wecare", manifest[1]["dataset"]
    assert_equal "subfolder", manifest[1]["full_path"]
    assert_equal "", manifest[1]["folder"]
    assert_equal "subfolder", manifest[1]["file_name"]
    assert_equal false, manifest[1]["is_file"]
    assert_equal 204, manifest[1]["file_size"]
    assert_nil manifest[1]["file_checksum_md5"]
    assert_equal false, manifest[1]["archived"]
    assert_equal "wecare", manifest[2]["dataset"]
    assert_equal "DOWNLOAD_ME.txt", manifest[2]["full_path"]
    assert_equal "", manifest[2]["folder"]
    assert_equal "DOWNLOAD_ME.txt", manifest[2]["file_name"]
    assert_equal true, manifest[2]["is_file"]
    assert_equal 16, manifest[2]["file_size"]
    assert_equal "be3aad0b46648b4867534a1b10ec6ed1", manifest[2]["file_checksum_md5"]
    assert_equal false, manifest[2]["archived"]
    assert_response :success
  end

  test "should not get unreleased manifest for unapproved user using auth token" do
    get :files, params: {
      id: datasets(:unreleased), auth_token: users(:valid).id_and_auth_token
    }, format: "json"
    assert_template nil
    assert_response :success
  end
end

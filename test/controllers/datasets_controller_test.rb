# frozen_string_literal: true

require "test_helper"

# Allows users to view and explore datasets.
class DatasetsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @dataset = datasets(:released)
  end

  test "should get editor status as editor" do
    get editor_dataset_url(datasets(:released), auth_token: users(:editor).id_and_auth_token, format: "json")
    assert_equal "{\"editor\":true,\"user_id\":#{users(:editor).id}}", response.body
    assert_response :success
  end

  test "should get non-editor status as viewer" do
    get editor_dataset_url(datasets(:released), auth_token: users(:valid).id_and_auth_token, format: "json")
    assert_equal "{\"editor\":false,\"user_id\":#{users(:valid).id}}", response.body
    assert_response :success
  end

  test "should get non-editor status as public user" do
    get editor_dataset_url(datasets(:released), auth_token: "none", format: "json")
    assert_equal '{"editor":false,"user_id":null}', response.body
    assert_response :success
  end

  test "should get folder progress as editor" do
    login(users(:editor))
    post folder_progress_dataset_url(datasets(:released), format: "js")
    assert_template "folder_progress"
    assert_response :success
  end

  test "should get public file from released dataset as viewer" do
    login(users(:valid))
    get files_dataset_url(id: datasets(:released), path: "PUBLIC_FILE.txt", format: "html")
    assert_equal File.read(assigns(:dataset).find_file("PUBLIC_FILE.txt")), response.body
  end

  test "should get public file from released dataset as public user" do
    get files_dataset_url(id: datasets(:released), path: "PUBLIC_FILE.txt", format: "html")
    assert_equal File.read(assigns(:dataset).find_file("PUBLIC_FILE.txt")), response.body
  end

  test "should get inline image for public dataset" do
    get images_dataset_url(@dataset, path: "rails.png", inline: "1")
    assert_not_nil assigns(:image_file)
    assert_template "images.html.haml"
  end

  test "should download image for public dataset" do
    get images_dataset_url(@dataset, path: "rails.png")
    assert_equal File.binread(File.join(assigns(:dataset).root_folder, "images", "rails.png")), response.body
  end

  test "should not download non-existent image for public dataset" do
    get images_dataset_url(id: @dataset, path: "where-is-rails.png")
    assert_nil assigns(:image_file)
    assert_response :success
  end

  test "should get folder from public dataset as anonymous user" do
    get files_dataset_url(@dataset, path: "subfolder")
    assert_template "files"
    assert_response :success
  end

  test "should not get redirect up a level for deleted subfolder from public dataset as anonymous user" do
    get files_dataset_url(@dataset, path: "deleted_subfolder")
    assert_redirected_to files_dataset_url(@dataset, path: "")
  end

  test "should get folder from public dataset as regular user" do
    login(users(:valid))
    get files_dataset_url(@dataset, path: "subfolder")
    assert_template "files"
    assert_response :success
  end

  test "should get files from public dataset as anonymous user" do
    get files_dataset_url(@dataset, path: "DOWNLOAD_ME.txt", format: "html")
    assert_equal File.read(assigns(:dataset).find_file("DOWNLOAD_ME.txt")), response.body
  end

  test "should get files from public dataset as regular user" do
    login(users(:valid))
    get files_dataset_url(@dataset, path: "DOWNLOAD_ME.txt", format: "html")
    assert_equal File.read(assigns(:dataset).find_file("DOWNLOAD_ME.txt")), response.body
  end

  test "should get file preview for image file in public dataset" do
    get files_dataset_url(@dataset, path: "previews/rails.png", preview: "1")
    assert_not_nil assigns(:dataset_file)
    assert_template "dataset_files/show"
    assert_response :success
  end

  test "should get file preview for markdown file in public dataset" do
    get files_dataset_url(@dataset, path: "previews/markup.md", preview: "1")
    assert_not_nil assigns(:dataset_file)
    assert_template "dataset_files/show"
    assert_response :success
  end

  test "should get file preview for pdf file in public dataset" do
    get files_dataset_url(@dataset, path: "previews/blank.pdf", preview: "1")
    assert_not_nil assigns(:dataset_file)
    assert_template "dataset_files/show"
    assert_response :success
  end

  test "should get inline file preview for pdf file in public dataset" do
    get files_dataset_url(@dataset, path: "previews/blank.pdf", inline: "1")
    assert_not_nil assigns(:dataset_file)
    assert_template nil
    assert_response :success
  end

  test "should display no files if root files folder does not exists" do
    get files_dataset_url(datasets(:released_with_no_files_folder))
    assert_template "files"
    assert_response :success
  end

  test "should get files from subfolder from public dataset as anonymous user" do
    get files_dataset_url(@dataset, path: "subfolder/1.txt", format: "html")
    assert_equal File.read(assigns(:dataset).find_file("subfolder/1.txt")), response.body
  end

  test "should get files from subfolder from public dataset as regular user" do
    login(users(:valid))
    get files_dataset_url(@dataset, path: "subfolder/1.txt", format: "html")
    assert_equal File.read(assigns(:dataset).find_file("subfolder/1.txt")), response.body
  end

  test "should not get files from unreleased dataset as anonymous user" do
    get files_dataset_url(datasets(:unreleased), path: "HIDDEN_FILE.txt", format: "html")
    assert_redirected_to datasets_url
  end

  test "should not get files from unreleased dataset as regular user" do
    login(users(:valid))
    get files_dataset_url(datasets(:unreleased), path: "HIDDEN_FILE.txt", format: "html")
    assert_redirected_to datasets_url
  end

  test "should get files from unreleased dataset as approved user using auth token" do
    get files_dataset_url(
      datasets(:unreleased),
      path: "HIDDEN_FILE.txt",
      auth_token: users(:insider1).id_and_auth_token,
      format: "html"
    )
    assert_equal File.read(assigns(:dataset).find_file("HIDDEN_FILE.txt")), response.body
  end

  test "should get logo from public dataset as anonymous user" do
    get logo_dataset_url(@dataset)
    assert_equal File.binread(assigns(:dataset).logo.path), response.body
  end

  test "should get logo from public dataset as regular user" do
    login(users(:valid))
    get logo_dataset_url(@dataset)
    assert_equal File.binread(assigns(:dataset).logo.path), response.body
  end

  test "should not get logo from unreleased dataset as anonymous user" do
    get logo_dataset_url(datasets(:unreleased))
    assert_redirected_to datasets_url
  end

  test "should not get logo from unreleased dataset as regular user" do
    login(users(:valid))
    get logo_dataset_url(datasets(:unreleased))
    assert_redirected_to datasets_url
  end

  test "should not get non-existant file from public dataset as anonymous user" do
    get files_dataset_url(@dataset, path: "subfolder/subsubfolder/3.txt", format: "html")
    assert_redirected_to files_dataset_url(assigns(:dataset), path: "subfolder")
  end

  test "should get index" do
    get datasets_url
    assert_response :success
  end

  test "should get index for logged in user" do
    login(users(:valid))
    get datasets_url
    assert_response :success
    assert_not_nil assigns(:datasets)
  end

  test "should get index as json" do
    get datasets_url(format: "json")
    assert_not_nil assigns(:datasets)
    datasets = JSON.parse(response.body)
    assert_equal 1, datasets.select { |d| d["slug"] == "released" }.count
    assert_equal 0, datasets.select { |d| d["slug"] == "unreleased" }.count
    assert_response :success
  end

  test "should get index as json for user with token" do
    get datasets_url(format: "json"), params: { auth_token: users(:admin).id_and_auth_token }
    assert_not_nil assigns(:datasets)
    datasets = JSON.parse(response.body)
    assert_equal 1, datasets.select { |d| d["slug"] == "released" }.count
    assert_equal 1, datasets.select { |d| d["slug"] == "unreleased" }.count
    assert_response :success
  end

  test "should get manifest" do
    get json_manifest_dataset_url(@dataset)
    assert_response :success
  end

  test "should get manifest using auth token" do
    get json_manifest_dataset_url(@dataset), params: { path: "subfolder", auth_token: users(:valid).id_and_auth_token }
    manifest = JSON.parse(response.body)
    assert_equal 5, manifest.size
    assert_equal "another_folder", manifest[0]["file_name"]
    assert_nil manifest[0]["checksum"]
    assert_equal false, manifest[0]["is_file"]
    assert_equal 102, manifest[0]["file_size"]
    assert_equal "released", manifest[0]["dataset"]
    assert_equal "subfolder/another_folder", manifest[0]["file_path"]
    assert_equal "1.txt", manifest[1]["file_name"]
    assert_equal "39061daa34ca3de20df03a88c52530ea", manifest[1]["checksum"]
    assert_equal true, manifest[1]["is_file"]
    assert_equal 6, manifest[1]["file_size"]
    assert_equal "released", manifest[1]["dataset"]
    assert_equal "subfolder/1.txt", manifest[1]["file_path"]
    assert_equal "2.txt", manifest[2]["file_name"]
    assert_equal "85c8f17e86771eb8480a44349e13127b", manifest[2]["checksum"]
    assert_equal true, manifest[2]["is_file"]
    assert_equal 6, manifest[2]["file_size"]
    assert_equal "released", manifest[2]["dataset"]
    assert_equal "subfolder/2.txt", manifest[2]["file_path"]
    assert_equal "IN_SUBFOLDER_NOT_PUBLIC_YET.txt", manifest[3]["file_name"]
    assert_equal "8a59dbfe009557d80a3467acbe141d65", manifest[3]["checksum"]
    assert_equal true, manifest[3]["is_file"]
    assert_equal 32, manifest[3]["file_size"]
    assert_equal "released", manifest[3]["dataset"]
    assert_equal "subfolder/IN_SUBFOLDER_NOT_PUBLIC_YET.txt", manifest[3]["file_path"]
    assert_equal "IN_SUBFOLDER_PUBLIC_FILE.txt", manifest[4]["file_name"]
    assert_equal "29423ee86b07cb966ea263a37e88669a", manifest[4]["checksum"]
    assert_equal true, manifest[4]["is_file"]
    assert_equal 29, manifest[4]["file_size"]
    assert_equal "released", manifest[4]["dataset"]
    assert_equal "subfolder/IN_SUBFOLDER_PUBLIC_FILE.txt", manifest[4]["file_path"]
    assert_response :success
  end

  test "should not get unreleased manifest for unapproved user using auth token" do
    get json_manifest_dataset_url(datasets(:unreleased)), params: { auth_token: users(:valid).id_and_auth_token }
    assert_redirected_to datasets_url
  end

  test "should show public dataset to logged out user as json" do
    get dataset_url(@dataset, format: "json")
    dataset = JSON.parse(response.body)
    assert_equal "We Care", dataset["name"]
    assert_equal "(A) Released dataset with documentation and public and private files.", dataset["description"]
    assert_equal "released", dataset["slug"]
    assert_equal true, dataset["released"]
    assert_not_nil dataset["created_at"]
    assert_not_nil dataset["updated_at"]
    assert_response :success
  end

  test "should show public dataset to anonymous user" do
    get dataset_url(@dataset)
    assert_response :success
  end

  test "should show public dataset to logged in user" do
    login(users(:valid))
    get dataset_url(@dataset)
    assert_response :success
  end

  test "should not show unreleased dataset to anonymous user" do
    get dataset_url(datasets(:unreleased))
    assert_redirected_to datasets_url
  end

  test "should show unreleased dataset to editor of unreleased dataset" do
    login(users(:editor_on_unreleased))
    get dataset_url(datasets(:unreleased))
    assert_response :success
  end

  test "should not show unreleased dataset to logged in user" do
    login(users(:valid))
    get dataset_url(datasets(:unreleased))
    assert_redirected_to datasets_url
  end

  test "should show unreleased dataset to authorized user with token" do
    get dataset_url(datasets(:unreleased), format: "json"), params: { auth_token: users(:admin).id_and_auth_token }
    assert_not_nil assigns(:dataset)
    dataset = JSON.parse(response.body)
    assert_equal "unreleased", dataset["slug"]
    assert_equal "In the Works", dataset["name"]
    assert_equal "(B) Unreleased dataset with documentation and public and private files.", dataset["description"]
    assert_equal false, dataset["released"]
    assert_response :success
  end

  test "should show public page to anonymous user" do
    assert_difference("DatasetPageAudit.count") do
      get pages_dataset_url(id: @dataset, path: "VIEW_ME.md", format: "html")
    end
    assert_response :success
  end

  test "should show public page to logged in user" do
    login(users(:valid))
    assert_difference("DatasetPageAudit.count") do
      get pages_dataset_url(id: @dataset, path: "VIEW_ME.md", format: "html")
    end
    assert_response :success
  end

  test "should show public page in subfolder to anonymous user" do
    assert_difference("DatasetPageAudit.count") do
      get pages_dataset_url(id: @dataset, path: "subfolder/MORE_INFO.txt", format: "html")
    end
    assert_response :success
  end

  test "should show public page in subfolder to logged in user" do
    login(users(:valid))
    assert_difference("DatasetPageAudit.count") do
      get pages_dataset_url(id: @dataset, path: "subfolder/MORE_INFO.txt", format: "html")
    end
    assert_response :success
  end

  test "should show directory of pages in subfolder" do
    get pages_dataset_url(id: @dataset, path: "subfolder", format: "html")
    assert_template "pages"
    assert_response :success
  end

  test "should not get non-existant page from public dataset as anonymous user" do
    get pages_dataset_url(id: @dataset, path: "subfolder/subsubfolder/3.md", format: "html")
    assert_redirected_to pages_dataset_url(assigns(:dataset), path: "subfolder")
  end

  test "should search public dataset documentation as anonymous user" do
    get search_dataset_url(@dataset), params: { search: "view ?/\\" }
    assert_equal "view", assigns(:term)
    assert_equal 1, assigns(:results).count
    assert_equal "# VIEW_ME.md", assigns(:results).first.to_s.split(":").last
    assert_template :search
    assert_response :success
  end
end

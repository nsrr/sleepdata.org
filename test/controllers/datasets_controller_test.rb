require 'test_helper'

class DatasetsControllerTest < ActionController::TestCase
  setup do
    @dataset = datasets(:public)
  end

  test "should get success if dataset csv is uploaded" do
    post :upload_dataset_csv, id: datasets(:public), auth_token: users(:editor).id_and_auth_token, file: fixture_file_upload('../../test/support/datasets/wecare/images/rails.png')

    assert_not_nil response
    assert_equal "{\"upload\":\"success\"}", response.body
    assert_response :success
  end

  test "should get failed if dataset csv does not exist after upload" do
    post :upload_dataset_csv, id: datasets(:public), auth_token: users(:editor).id_and_auth_token, file: ""

    assert_not_nil response
    assert_equal "{\"upload\":\"failed\"}", response.body
    assert_response :success
  end

  test "should get success if graph is uploaded" do
    post :upload_graph, id: datasets(:public), auth_token: users(:editor).id_and_auth_token, file: fixture_file_upload('../../test/support/datasets/wecare/images/rails.png')

    assert_not_nil response
    assert_equal "{\"upload\":\"success\"}", response.body
    assert_response :success
  end

  test "should get failed if graph does not exist after upload" do
    post :upload_graph, id: datasets(:public), auth_token: users(:editor).id_and_auth_token, file: ""

    assert_not_nil response
    assert_equal "{\"upload\":\"failed\"}", response.body
    assert_response :success
  end

  test "should get editor status as editor" do
    get :editor, id: datasets(:public), auth_token: users(:editor).id_and_auth_token, format: 'json'

    assert_not_nil response
    assert_equal "{\"editor\":true,\"user_id\":#{users(:editor).id}}", response.body
    assert_response :success
  end

  test "should get non-editor status as viewer" do
    get :editor, id: datasets(:mixed), auth_token: users(:valid).id_and_auth_token, format: 'json'

    assert_not_nil response
    assert_equal "{\"editor\":false,\"user_id\":#{users(:valid).id}}", response.body
    assert_response :success
  end

  test "should get non-editor status as anonymous" do
    get :editor, id: datasets(:public), auth_token: "", format: 'json'

    assert_not_nil response
    assert_equal "{\"editor\":false,\"user_id\":null}", response.body
    assert_response :success
  end

  test "should reset index as editor" do
    login(users(:editor_mixed))
    post :reset_index, id: datasets(:mixed), path: nil

    assert_redirected_to files_dataset_path(assigns(:dataset), path: '')
  end

  test "should not reset index as viewer" do
    login(users(:valid))
    post :reset_index, id: datasets(:mixed), path: nil

    assert_redirected_to datasets_path
  end

  test "should not reset index as anonymous" do
    post :reset_index, id: datasets(:mixed), path: nil
    assert_redirected_to new_user_session_path
  end


  test "should set file as public as editor" do
    login(users(:editor_mixed))
    assert_difference('PublicFile.count') do
      post :set_public_file, id: datasets(:mixed), path: 'NOT_PUBLIC_YET.txt', public: '1'
    end

    assert_redirected_to files_dataset_path(assigns(:dataset), path: '')
  end

  test "should set file as private as editor" do
    login(users(:editor_mixed))
    assert_difference('PublicFile.count', -1) do
      post :set_public_file, id: datasets(:mixed), path: 'PUBLIC_FILE.txt', public: '0'
    end

    assert_redirected_to files_dataset_path(assigns(:dataset), path: '')
  end

  test "should set file in subfolder as public as editor" do
    login(users(:editor_mixed))
    assert_difference('PublicFile.count') do
      post :set_public_file, id: datasets(:mixed), path: 'subfolder/IN_SUBFOLDER_NOT_PUBLIC_YET.txt', public: '1'
    end

    assert_redirected_to files_dataset_path(assigns(:dataset), path: 'subfolder')
  end

  test "should set file in subfolder as private as editor" do
    login(users(:editor_mixed))
    assert_difference('PublicFile.count', -1) do
      post :set_public_file, id: datasets(:mixed), path: 'subfolder/IN_SUBFOLDER_PUBLIC_FILE.txt', public: '0'
    end

    assert_redirected_to files_dataset_path(assigns(:dataset), path: 'subfolder')
  end

  test "should not set file as public as viewer" do
    login(users(:valid))
    assert_difference('PublicFile.count', 0) do
      post :set_public_file, id: datasets(:mixed), path: 'NOT_PUBLIC_YET.txt', public: '1'
    end

    assert_redirected_to datasets_path
  end

  test "should not set file as public as anonymous" do
    assert_difference('PublicFile.count', 0) do
      post :set_public_file, id: datasets(:mixed), path: 'NOT_PUBLIC_YET.txt', public: '1'
    end

    assert_redirected_to new_user_session_path
  end

  test "should get public file from mixed dataset as viewer" do
    login(users(:valid))
    get :files, id: datasets(:mixed), path: 'PUBLIC_FILE.txt'

    assert_not_nil response

    assert_kind_of String, response.body
    assert_equal File.read(assigns(:dataset).find_file('PUBLIC_FILE.txt')), response.body
  end

  test "should get public file from mixed dataset as anonymous user" do
    get :files, id: datasets(:mixed), path: 'PUBLIC_FILE.txt'

    assert_not_nil response

    assert_kind_of String, response.body
    assert_equal File.read(assigns(:dataset).find_file('PUBLIC_FILE.txt')), response.body
  end

  test "should show requests to editor" do
    login(users(:editor))
    get :requests, id: @dataset
    assert_response :success
  end

  test "should get inline image for public dataset" do
    get :images, id: @dataset, path: 'rails.png', inline: '1'
    assert_not_nil assigns(:image_file)
    assert_template 'images'
  end

  test "should download image for public dataset" do
    get :images, id: @dataset, path: 'rails.png'
    assert_not_nil assigns(:image_file)
    assert_kind_of String, response.body
    assert_equal File.binread( File.join(assigns(:dataset).root_folder, 'images', 'rails.png') ), response.body
  end

  test "should not download non-existent image for public dataset" do
    get :images, id: @dataset, path: 'where-is-rails.png'
    assert_nil assigns(:image_file)
    assert_response :success
  end

  test "should get folder from public dataset as anonymous user" do
    get :files, id: @dataset, path: 'subfolder'

    assert_template 'files'
    assert_response :success
  end

  test "should get folder from public dataset as regular user" do
    login(users(:valid))
    get :files, id: @dataset, path: 'subfolder'

    assert_template 'files'
    assert_response :success
  end

  test "should get files from public dataset as anonymous user" do
    get :files, id: @dataset, path: 'DOWNLOAD_ME.txt'

    assert_not_nil response

    assert_kind_of String, response.body
    assert_equal File.read(assigns(:dataset).find_file('DOWNLOAD_ME.txt')), response.body
  end

  test "should get files from public dataset as regular user" do
    login(users(:valid))
    get :files, id: @dataset, path: 'DOWNLOAD_ME.txt'

    assert_not_nil response

    assert_kind_of String, response.body
    assert_equal File.read(assigns(:dataset).find_file('DOWNLOAD_ME.txt')), response.body
  end

  test "should redirect to dataset if no files folder exists" do
    get :files, id: datasets(:public_with_no_files_folder)

    assert_not_nil assigns(:dataset)
    assert_redirected_to assigns(:dataset)
  end

  test "should get files from subfolder from public dataset as anonymous user" do
    get :files, id: @dataset, path: 'subfolder/1.txt'

    assert_not_nil response

    assert_kind_of String, response.body
    assert_equal File.read(assigns(:dataset).find_file('subfolder/1.txt')), response.body
  end

  test "should get files from subfolder from public dataset as regular user" do
    login(users(:valid))
    get :files, id: @dataset, path: 'subfolder/1.txt'

    assert_not_nil response

    assert_kind_of String, response.body
    assert_equal File.read(assigns(:dataset).find_file('subfolder/1.txt')), response.body
  end

  test "should not get files from private dataset as anonymous user" do
    get :files, id: datasets(:private), path: 'HIDDEN_FILE.txt'

    assert_redirected_to datasets_path
  end

  test "should not get files from private dataset as regular user" do
    login(users(:valid))
    get :files, id: datasets(:private), path: 'HIDDEN_FILE.txt'

    assert_redirected_to datasets_path
  end

  test "should get files from private dataset as approved user using auth token" do
    get :files, id: datasets(:private), path: 'HIDDEN_FILE.txt', auth_token: users(:two).id_and_auth_token

    assert_not_nil response
    assert_not_nil assigns(:dataset)

    assert_kind_of String, response.body
    assert_equal File.read(assigns(:dataset).find_file('HIDDEN_FILE.txt')), response.body
  end

  test "should get logo from public dataset as anonymous user" do
    get :logo, id: @dataset

    assert_not_nil response

    assert_kind_of String, response.body
    assert_equal File.binread( File.join(CarrierWave::Uploader::Base.root, assigns(:dataset).logo.url) ), response.body
  end

  test "should get logo from public dataset as regular user" do
    login(users(:valid))
    get :logo, id: @dataset

    assert_not_nil response

    assert_kind_of String, response.body
    assert_equal File.binread( File.join(CarrierWave::Uploader::Base.root, assigns(:dataset).logo.url) ), response.body
  end

  test "should not get logo from private dataset as anonymous user" do
    get :logo, id: datasets(:private)

    assert_redirected_to datasets_path
  end

  test "should not get logo from private dataset as regular user" do
    login(users(:valid))
    get :logo, id: datasets(:private)

    assert_redirected_to datasets_path
  end

  test "should not get non-existant file from public dataset as anonymous user" do
    get :files, id: @dataset, path: 'subfolder/subsubfolder/3.txt'

    assert_redirected_to files_dataset_path( assigns(:dataset), path: 'subfolder' )
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:datasets)
  end

  test "should get index for logged in user" do
    login(users(:valid))
    get :index
    assert_response :success
    assert_not_nil assigns(:datasets)
  end

  test "should get index as json" do
    get :index, format: 'json'
    assert_not_nil assigns(:datasets)
    datasets = JSON.parse(response.body)
    assert_equal 1, datasets.select{|d| d['slug'] == 'wecare'}.count
    assert_equal 0, datasets.select{|d| d['slug'] == 'private'}.count
    assert_response :success
  end

  test "should get index as json for user with token" do
    get :index, auth_token: users(:admin).id_and_auth_token, format: 'json'
    assert_not_nil assigns(:datasets)
    datasets = JSON.parse(response.body)
    assert_equal 1, datasets.select{|d| d['slug'] == 'wecare'}.count
    assert_equal 1, datasets.select{|d| d['slug'] == 'private'}.count
    assert_response :success
  end

  test "should get new" do
    login(users(:admin))
    get :new
    assert_response :success
  end

  test "should create dataset" do
    login(users(:admin))
    assert_difference('Dataset.count') do
      post :create, dataset: { name: 'New Dataset', description: @dataset.description, logo: fixture_file_upload('../../test/support/datasets/wecare/images/rails.png'), public: true, slug: 'new-dataset', release_date: '2014-06-23' }
    end

    assert_redirected_to dataset_path(assigns(:dataset))
  end

  test "should not create dataset as anonymous user" do
    assert_difference('Dataset.count', 0) do
      post :create, dataset: { name: 'New Dataset', description: @dataset.description, logo: fixture_file_upload('../../test/support/datasets/wecare/images/rails.png'), public: true, slug: 'new-dataset', release_date: '2014-06-23' }
    end

    assert_redirected_to new_user_session_path
  end

  test "should not create dataset as regular user" do
    login(users(:valid))
    assert_difference('Dataset.count', 0) do
      post :create, dataset: { name: 'New Dataset', description: @dataset.description, logo: fixture_file_upload('../../test/support/datasets/wecare/images/rails.png'), public: true, slug: 'new-dataset', release_date: '2014-06-23' }
    end

    assert_redirected_to root_path
  end

  test "should not create dataset with blank name" do
    login(users(:admin))
    assert_difference('Dataset.count', 0) do
      post :create, dataset: { name: '', description: @dataset.description, logo: fixture_file_upload('../../test/support/datasets/wecare/images/rails.png'), public: true, slug: 'new-dataset', release_date: '2014-06-23' }
    end

    assert assigns(:dataset).errors.size > 0
    assert_equal ["can't be blank"], assigns(:dataset).errors[:name]

    assert_template 'new'
  end

  test "should not create dataset existing slug" do
    login(users(:admin))
    assert_difference('Dataset.count', 0) do
      post :create, dataset: { name: 'We Care Imposter', description: @dataset.description, logo: fixture_file_upload('../../test/support/datasets/wecare/images/rails.png'), public: true, slug: 'wecare' }
    end

    assert assigns(:dataset).errors.size > 0
    assert_equal ["has already been taken"], assigns(:dataset).errors[:slug]

    assert_template 'new'
  end

  test "should get manifest" do
    get :json_manifest, id: @dataset
    assert_response :success
  end

  test "should get manifest using auth token" do
    get :json_manifest, id: @dataset, path: 'subfolder', auth_token: users(:valid).id_and_auth_token

    manifest = JSON.parse(response.body)

    manifest.sort_by!{|item| [item['is_file'].to_s,item['file_name'].to_s]}

    assert_equal 3, manifest.size

    assert_equal 'anotherfolder', manifest[0]['file_name']
    assert_equal nil, manifest[0]['checksum']
    assert_equal false, manifest[0]['is_file']
    assert_not_nil manifest[0]['file_size']
    assert_equal 'wecare', manifest[0]['dataset']
    assert_equal 'subfolder/anotherfolder', manifest[0]['file_path']

    assert_equal '1.txt', manifest[1]['file_name']
    assert_equal '39061daa34ca3de20df03a88c52530ea', manifest[1]['checksum']
    assert_equal true, manifest[1]['is_file']
    assert_not_nil manifest[1]['file_size']
    assert_equal 'wecare', manifest[1]['dataset']
    assert_equal 'subfolder/1.txt', manifest[1]['file_path']

    assert_equal '2.txt', manifest[2]['file_name']
    assert_equal '85c8f17e86771eb8480a44349e13127b', manifest[2]['checksum']
    assert_equal true, manifest[2]['is_file']
    assert_not_nil manifest[2]['file_size']
    assert_equal 'wecare', manifest[2]['dataset']
    assert_equal 'subfolder/2.txt', manifest[2]['file_path']

    assert_response :success
  end

  test "should not get private manifest for unapproved user using auth token" do
    get :json_manifest, id: datasets(:private), auth_token: users(:valid).id_and_auth_token
    assert_redirected_to datasets_path
  end

  test "should show public dataset to logged out user as json" do
    get :show, id: @dataset, format: 'json'

    dataset = JSON.parse(response.body)

    assert_equal 'We Care',  dataset['name']
    assert_equal 'The We Care Clinical Trial dataset', dataset['description']
    assert_equal 'wecare', dataset['slug']
    assert_equal true, dataset['public']
    assert_not_nil dataset['created_at']
    assert_not_nil dataset['updated_at']

    assert_response :success
  end

  test "should show public dataset to anonymous user" do
    get :show, id: @dataset
    assert_response :success
  end

  test "should show public dataset to logged in user" do
    login(users(:valid))
    get :show, id: @dataset
    assert_response :success
  end

  test "should not show private dataset to anonymous user" do
    get :show, id: datasets(:private)
    assert_redirected_to datasets_path
  end

  test "should show private dataset to editor of private dataset" do
    login(users(:editor_on_private))
    get :show, id: datasets(:private)
    assert_response :success
  end

  test "should not show private dataset to logged in user" do
    login(users(:valid))
    get :show, id: datasets(:private)
    assert_redirected_to datasets_path
  end

  test "should show private dataset to authorized user with token" do
    get :show, id: datasets(:private), auth_token: users(:admin).id_and_auth_token, format: 'json'
    assert_not_nil assigns(:dataset)
    dataset = JSON.parse(response.body)
    assert_equal 'private', dataset['slug']
    assert_equal 'In the Works', dataset['name']
    assert_equal 'Currently being constructed and not yet public.', dataset['description']
    assert_equal false, dataset['public']
    assert_response :success
  end

  test "should show public page to anonymous user" do
    assert_difference('DatasetPageAudit.count') do
      get :pages, id: @dataset, path: 'VIEW_ME.md'
    end
    assert_response :success
  end

  test "should show public page to logged in user" do
    login(users(:valid))
    assert_difference('DatasetPageAudit.count') do
      get :pages, id: @dataset, path: 'VIEW_ME.md'
    end
    assert_response :success
  end

  test "should show public page in subfolder to anonymous user" do
    assert_difference('DatasetPageAudit.count') do
      get :pages, id: @dataset, path: 'subfolder/MORE_INFO.txt'
    end
    assert_response :success
  end

  test "should show public page in subfolder to logged in user" do
    login(users(:valid))
    assert_difference('DatasetPageAudit.count') do
      get :pages, id: @dataset, path: 'subfolder/MORE_INFO.txt'
    end
    assert_response :success
  end

  test "should show directory of pages in subfolder" do
    get :pages, id: @dataset, path: 'subfolder'
    assert_template 'pagesbeta'
    assert_response :success
  end

  test "should not get non-existant page from public dataset as anonymous user" do
    get :pages, id: @dataset, path: 'subfolder/subsubfolder/3.md'
    assert_redirected_to pages_dataset_path( assigns(:dataset), path: 'subfolder' )
  end

  test "should search public dataset documentation as anonymous user" do
    get :search, id: @dataset, s: 'view ?/\\'
    assert_equal 'view', assigns(:term)
    assert_equal 1, assigns(:results).count
    assert_equal '# VIEW_ME.md', assigns(:results).first.to_s.split(':').last
    assert_template :search
    assert_response :success
  end

  test "should get edit" do
    login(users(:editor))
    get :edit, id: @dataset
    assert_response :success
  end

  test "should create page as editor" do
    login(users(:editor))
    post :create_page, id: @dataset, page_name: 'CREATE_ME.md', page_contents: "# CREATE ME\nThis is the `CREATE_ME.md`."

    assert_redirected_to pages_dataset_path(assigns(:dataset), path: assigns(:path))

    # Clean up file so tests can be rerun
    file_path = Rails.root.join('test', 'support', 'datasets', 'wecare', 'pages', 'CREATE_ME.md')
    File.delete(file_path) if File.exist?(file_path)
  end

  test "should not create page without a name as editor" do
    login(users(:editor))
    post :create_page, id: @dataset, page_name: '', page_contents: "Oh no, no name!"

    assert assigns(:errors).size > 0
    assert_equal "Page name can't be blank", assigns(:errors)[:page_name]

    assert_template 'new_page'
  end

  test "should not create already existing page as editor" do
    login(users(:editor))
    post :create_page, id: @dataset, page_name: 'VIEW_ME.md', page_contents: "Oh no, it already exists!"

    assert assigns(:errors).size > 0
    assert_equal "A page with that name already exists", assigns(:errors)[:page_name]

    assert_template 'new_page'
  end

  test "should get edit_page as editor" do
    login(users(:editor))
    get :edit_page, id: @dataset, path: 'EDIT_ME.md'
    assert_response :success
  end

  test "should update_page as editor" do
    login(users(:editor))
    patch :update_page, id: @dataset, path: 'EDIT_ME.md', page_contents: "# NEW TITLE\nThis is describing the dataset using documentation.\n"
    assert_equal File.read(assigns(:dataset).find_page('EDIT_ME.md')), "# NEW TITLE\nThis is describing the dataset using documentation.\n"
    assert_redirected_to pages_dataset_path(assigns(:dataset), path: assigns(:path))
  end

  test "should not get edit_page as editor of invalid page" do
    login(users(:editor))
    get :edit_page, id: @dataset, path: 'wrongfolder/1.txt'
    assert_redirected_to pages_dataset_path(assigns(:dataset), path: assigns(:path))
  end

  test "should update dataset" do
    login(users(:editor))
    patch :update, id: @dataset, dataset: { name: 'We Care Name Updated', description: @dataset.description, public: @dataset.public, slug: @dataset.slug }
    assert_equal assigns(:dataset).name, 'We Care Name Updated'
    assert_redirected_to dataset_path(assigns(:dataset))
  end

  test "should not update dataset with blank name" do
    login(users(:editor))
    patch :update, id: @dataset, dataset: { name: '', description: @dataset.description, public: @dataset.public, slug: @dataset.slug }

    assert assigns(:dataset).errors.size > 0
    assert_equal ["can't be blank"], assigns(:dataset).errors[:name]

    assert_template 'edit'
  end

  test "should not update dataset with existing slug" do
    login(users(:editor))
    patch :update, id: @dataset, dataset: { name: '', description: @dataset.description, public: @dataset.public, slug: 'private' }

    assert assigns(:dataset).errors.size > 0
    assert_equal ["has already been taken"], assigns(:dataset).errors[:slug]

    assert_template 'edit'
  end

  test "should destroy dataset" do
    login(users(:admin))
    assert_difference('Dataset.current.count', -1) do
      delete :destroy, id: @dataset
    end

    assert_redirected_to datasets_path
  end

  test "should get audits" do
    login(users(:editor))
    get :audits, id: @dataset
    assert_not_nil assigns(:audits)
    assert_response :success
  end

  test "should create access role to dataset" do
    login(users(:editor))
    assert_difference('DatasetUser.count') do
      post :create_access, id: @dataset, user_id: users(:aug).id, role: 'editor'
    end

    assert_not_nil assigns(:dataset_user)
    assert_equal 'editor', assigns(:dataset_user).role
    assert_equal users(:aug), assigns(:dataset_user).user

    assert_redirected_to requests_dataset_path(assigns(:dataset), dataset_user_id: assigns(:dataset_user).id)
  end

  test "should find existing access when creating access request to dataset" do
    login(users(:editor))
    assert_difference('DatasetUser.count', 0) do
      post :create_access, id: @dataset, user_id: users(:two).id
    end

    assert_not_nil assigns(:dataset_user)
    assert_equal nil, assigns(:dataset_user).approved
    assert_equal false, assigns(:dataset_user).editor
    assert_equal users(:two), assigns(:dataset_user).user

    assert_redirected_to requests_dataset_path(assigns(:dataset), dataset_user_id: assigns(:dataset_user).id)
  end
end

require 'test_helper'

class DatasetsControllerTest < ActionController::TestCase
  setup do
    @dataset = datasets(:public)
  end

  test "should add variable to list" do
    assert_difference('List.count') do
      post :add_variable_to_list, id: @dataset, variable_id: variables(:one).id, format: 'js'
    end

    assert_not_nil cookies.signed[:list_id]
    assert_not_nil assigns(:list)
    assert_equal 1, assigns(:list).variables(nil).size

    assert_template 'add_variable_to_list'
  end

  test "should add variable to existing list" do
    cookies.signed[:list_id] = lists(:one).id
    assert_difference('List.count', 0) do
      post :add_variable_to_list, id: @dataset, variable_id: variables(:one).id, format: 'js'
    end

    assert_not_nil cookies.signed[:list_id]
    assert_not_nil assigns(:list)
    assert_equal 2, assigns(:list).variables(nil).size

    assert_template 'add_variable_to_list'
  end

  test "should remove variable from list" do
    cookies.signed[:list_id] = lists(:one).id
    post :remove_variable_from_list, id: @dataset, variable_id: variables(:two).id, format: 'js'

    assert_not_nil cookies.signed[:list_id]
    assert_not_nil assigns(:list)
    assert_equal 0, assigns(:list).variables(nil).size

    assert_template 'add_variable_to_list'
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

  test "should get variable chart for public dataset" do
    get :variable_chart, id: @dataset, name: 'gender'
    assert_kind_of String, response.body
    assert_equal File.binread( File.join(assigns(:dataset).root_folder, 'dd', 'pngs', 'gender.png') ), response.body
  end

  test "should not get non-existent variable chart for public dataset" do
    get :variable_chart, id: @dataset, name: 'where-is-gender'
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

  test "should get new" do
    login(users(:admin))
    get :new
    assert_response :success
  end

  test "should create dataset" do
    login(users(:admin))
    assert_difference('Dataset.count') do
      post :create, dataset: { name: 'New Dataset', description: @dataset.description, logo: fixture_file_upload('../../test/support/datasets/wecare/images/rails.png'), public: true, slug: 'new_dataset' }
    end

    assert_redirected_to dataset_path(assigns(:dataset))
  end

  test "should not create dataset as anonymous user" do
    assert_difference('Dataset.count', 0) do
      post :create, dataset: { name: 'New Dataset', description: @dataset.description, logo: fixture_file_upload('../../test/support/datasets/wecare/images/rails.png'), public: true, slug: 'new_dataset' }
    end

    assert_redirected_to new_user_session_path
  end

  test "should not create dataset as regular user" do
    login(users(:valid))
    assert_difference('Dataset.count', 0) do
      post :create, dataset: { name: 'New Dataset', description: @dataset.description, logo: fixture_file_upload('../../test/support/datasets/wecare/images/rails.png'), public: true, slug: 'new_dataset' }
    end

    assert_redirected_to root_path
  end

  test "should not create dataset with blank name" do
    login(users(:admin))
    assert_difference('Dataset.count', 0) do
      post :create, dataset: { name: '', description: @dataset.description, logo: fixture_file_upload('../../test/support/datasets/wecare/images/rails.png'), public: true, slug: 'new_dataset' }
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
    get :manifest, id: @dataset
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

  test "should not show private dataset to logged in user" do
    login(users(:valid))
    get :show, id: datasets(:private)
    assert_redirected_to datasets_path
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
    assert_template 'pages'
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
    patch :update, id: @dataset, dataset: { name: '', description: @dataset.description, public: @dataset.public, slug: 'intheworks' }

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

  test "should request access to public dataset" do
    login(users(:valid))
    assert_difference('DatasetUser.count') do
      get :request_access, id: @dataset
    end

    assert_not_nil assigns(:dataset_user)
    assert_equal nil, assigns(:dataset_user).approved
    assert_equal false, assigns(:dataset_user).editor
    assert_equal users(:valid), assigns(:dataset_user).user

    assert_redirected_to dataset_path(assigns(:dataset))
  end

  test "should not create additional requests with existing request" do
    login(users(:two))
    assert_difference('DatasetUser.count', 0) do
      get :request_access, id: @dataset
    end

    assert_not_nil assigns(:dataset_user)
    assert_equal nil, assigns(:dataset_user).approved
    assert_equal false, assigns(:dataset_user).editor
    assert_equal users(:two), assigns(:dataset_user).user

    assert_redirected_to dataset_path(assigns(:dataset))
  end

  test "should approve access request to dataset" do
    login(users(:editor))
    patch :set_access, id: @dataset, dataset_user_id: dataset_users(:pending_public_access).id, approved: true, editor: false

    assert_not_nil assigns(:dataset_user)
    assert_equal true, assigns(:dataset_user).approved
    assert_equal false, assigns(:dataset_user).editor
    assert_equal users(:two), assigns(:dataset_user).user

    assert_redirected_to requests_dataset_path(assigns(:dataset))
  end
end

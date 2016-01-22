require 'test_helper'

# Tests access to upload and view images in blogs and forum posts
class ImagesControllerTest < ActionController::TestCase
  setup do
    @image = images(:one)
  end

  test 'should get index as admin' do
    login(users(:admin))
    get :index
    assert_response :success
    assert_not_nil assigns(:images)
  end

  test 'should not get index as public user' do
    get :index
    assert_redirected_to new_user_session_path
  end

  test 'should not get index as regular user' do
    login(users(:valid))
    get :index
    assert_redirected_to root_path
  end

  test 'should get new as admin' do
    login(users(:admin))
    get :new
    assert_response :success
  end

  test 'should get new as regular user' do
    login(users(:valid))
    get :new
    assert_response :success
  end

  test 'should not get new as public user' do
    get :new
    assert_redirected_to new_user_session_path
  end

  test 'should create image as admin' do
    login(users(:admin))
    assert_difference('Image.count') do
      post :create, params: { image: { image: fixture_file_upload('../../test/support/images/rails.png') } }
    end

    assert_redirected_to image_path(assigns(:image))
  end

  test 'should create image as regular user' do
    login(users(:valid))
    assert_difference('Image.count') do
      post :create, params: { image: { image: fixture_file_upload('../../test/support/images/rails.png') } }
    end

    assert_redirected_to image_path(assigns(:image))
  end

  test 'should create image as public user' do
    assert_difference('Image.count', 0) do
      post :create, params: { image: { image: fixture_file_upload('../../test/support/images/rails.png') } }
    end

    assert_redirected_to new_user_session_path
  end

  test 'should upload multiple images as admin' do
    login(users(:admin))
    assert_difference('Image.count', 2) do
      post :create_multiple, params: { images: [fixture_file_upload('../../test/support/images/rails.png'), fixture_file_upload('../../test/support/images/rails.png')], format: 'js' }
    end

    assert_template 'create_multiple'
    assert_response :success
  end

  test 'should upload multiple images as regular user' do
    login(users(:valid))
    assert_difference('Image.count', 2) do
      post :create_multiple, params: { images: [fixture_file_upload('../../test/support/images/rails.png'), fixture_file_upload('../../test/support/images/rails.png')], format: 'js' }
    end

    assert_template 'create_multiple'
    assert_response :success
  end

  test 'should not upload multiple images as public user' do
    assert_difference('Image.count', 0) do
      post :create_multiple, params: { images: [fixture_file_upload('../../test/support/images/rails.png'), fixture_file_upload('../../test/support/images/rails.png')], format: 'js' }
    end

    assert_response :unauthorized
  end

  test 'should show image as admin' do
    login(users(:admin))
    get :show, params: { id: @image }
    assert_response :success
  end

  test 'should show image as regular user' do
    login(users(:valid))
    get :show, params: { id: @image }
    assert_response :success
  end

  test 'should show image as public user' do
    get :show, params: { id: @image }
    assert_response :success
  end

  test 'should download image as admin' do
    login(users(:admin))
    get :download, params: { id: @image }
    assert_not_nil assigns(:image)
    assert_kind_of String, response.body
    assert_equal File.binread(File.join(CarrierWave::Uploader::Base.root, assigns(:image).image.url)), response.body
    assert_response :success
  end

  test 'should download image as regular user' do
    login(users(:valid))
    get :download, params: { id: @image }
    assert_not_nil assigns(:image)
    assert_kind_of String, response.body
    assert_equal File.binread(File.join(CarrierWave::Uploader::Base.root, assigns(:image).image.url)), response.body
    assert_response :success
  end

  test 'should download image as public user' do
    get :download, params: { id: @image }
    assert_not_nil assigns(:image)
    assert_kind_of String, response.body
    assert_equal File.binread(File.join(CarrierWave::Uploader::Base.root, assigns(:image).image.url)), response.body
    assert_response :success
  end

  test 'should get edit as admin' do
    login(users(:admin))
    get :edit, params: { id: @image }
    assert_response :success
  end

  test 'should not get edit as regular user' do
    login(users(:valid))
    get :edit, params: { id: @image }
    assert_redirected_to root_path
  end

  test 'should not get edit as public user' do
    get :edit, params: { id: @image }
    assert_redirected_to new_user_session_path
  end

  test 'should update image as admin' do
    login(users(:admin))
    patch :update, params: { id: images(:three), image: { image: fixture_file_upload('../../test/support/images/rails.png') } }
    assert_redirected_to image_path(assigns(:image))
  end

  test 'should not update image as regular user' do
    login(users(:valid))
    patch :update, params: { id: images(:three), image: { image: fixture_file_upload('../../test/support/images/rails.png') } }
    assert_redirected_to root_path
  end

  test 'should not update image as public user' do
    patch :update, params: { id: images(:three), image: { image: fixture_file_upload('../../test/support/images/rails.png') } }
    assert_redirected_to new_user_session_path
  end

  test 'should destroy image as admin' do
    login(users(:admin))
    assert_difference('Image.count', -1) do
      delete :destroy, params: { id: @image }
    end

    assert_redirected_to images_path
  end

  test 'should not destroy image as regular user' do
    login(users(:valid))
    assert_difference('Image.count', 0) do
      delete :destroy, params: { id: @image }
    end

    assert_redirected_to root_path
  end

  test 'should not destroy image as public user' do
    assert_difference('Image.count', 0) do
      delete :destroy, params: { id: @image }
    end

    assert_redirected_to new_user_session_path
  end
end

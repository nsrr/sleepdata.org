# frozen_string_literal: true

require "test_helper"

# Tests access to upload and view images in blogs and forum posts.
class ImagesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @image = images(:one)
  end

  test "should get index as admin" do
    login(users(:admin))
    get images_url
    assert_response :success
    assert_not_nil assigns(:images)
  end

  test "should not get index as public user" do
    get images_url
    assert_redirected_to new_user_session_url
  end

  test "should not get index as regular user" do
    login(users(:valid))
    get images_url
    assert_redirected_to root_url
  end

  test "should get new as admin" do
    login(users(:admin))
    get new_image_url
    assert_response :success
  end

  test "should get new as regular user" do
    login(users(:valid))
    get new_image_url
    assert_response :success
  end

  test "should not get new as public user" do
    get new_image_url
    assert_redirected_to new_user_session_url
  end

  test "should create image as admin" do
    login(users(:admin))
    assert_difference("Image.count") do
      post images_url, params: { image: { image: fixture_file_upload("../../test/support/images/rails.png") } }
    end

    assert_redirected_to image_url(assigns(:image))
  end

  test "should create image as regular user" do
    login(users(:valid))
    assert_difference("Image.count") do
      post images_url, params: { image: { image: fixture_file_upload("../../test/support/images/rails.png") } }
    end

    assert_redirected_to image_url(assigns(:image))
  end

  test "should create image as public user" do
    assert_difference("Image.count", 0) do
      post images_url, params: { image: { image: fixture_file_upload("../../test/support/images/rails.png") } }
    end

    assert_redirected_to new_user_session_url
  end

  test "should upload multiple images as admin" do
    login(users(:admin))
    assert_difference("Image.count", 2) do
      post upload_images_url(format: "js"), params: {
        images: [
          fixture_file_upload("../../test/support/images/rails.png"),
          fixture_file_upload("../../test/support/images/rails.png")
        ]
      }
    end

    assert_template "create_multiple"
    assert_response :success
  end

  test "should upload multiple images as regular user" do
    login(users(:valid))
    assert_difference("Image.count", 2) do
      post upload_images_url(format: "js"), params: {
        images: [
          fixture_file_upload("../../test/support/images/rails.png"),
          fixture_file_upload("../../test/support/images/rails.png")
        ]
      }
    end

    assert_template "create_multiple"
    assert_response :success
  end

  test "should not upload multiple images as public user" do
    assert_difference("Image.count", 0) do
      post upload_images_url(format: "js"), params: {
        images: [
          fixture_file_upload("../../test/support/images/rails.png"),
          fixture_file_upload("../../test/support/images/rails.png")
        ]
      }
    end

    assert_response :unauthorized
  end

  test "should show image as admin" do
    login(users(:admin))
    get image_url(@image)
    assert_response :success
  end

  test "should show image as regular user" do
    login(users(:valid))
    get image_url(@image)
    assert_response :success
  end

  test "should show image as public user" do
    get image_url(@image)
    assert_response :success
  end

  test "should download image as admin" do
    login(users(:admin))
    get download_image_url(@image)
    assert_equal File.binread(assigns(:image).image.path), response.body
    assert_response :success
  end

  test "should download image as regular user" do
    login(users(:valid))
    get download_image_url(@image)
    assert_equal File.binread(assigns(:image).image.path), response.body
    assert_response :success
  end

  test "should download image as public user" do
    get download_image_url(@image)
    assert_equal File.binread(assigns(:image).image.path), response.body
    assert_response :success
  end

  test "should get edit as admin" do
    login(users(:admin))
    get edit_image_url(@image)
    assert_response :success
  end

  test "should not get edit as regular user" do
    login(users(:valid))
    get edit_image_url(@image)
    assert_redirected_to root_url
  end

  test "should not get edit as public user" do
    get edit_image_url(@image)
    assert_redirected_to new_user_session_url
  end

  test "should update image as admin" do
    login(users(:admin))
    patch image_url(images(:three)), params: {
      image: { image: fixture_file_upload("../../test/support/images/rails.png") }
    }
    assert_redirected_to image_url(assigns(:image))
  end

  test "should not update image as regular user" do
    login(users(:valid))
    patch image_url(images(:three)), params: {
      image: { image: fixture_file_upload("../../test/support/images/rails.png") }
    }
    assert_redirected_to root_url
  end

  test "should not update image as public user" do
    patch image_url(images(:three)), params: {
      image: { image: fixture_file_upload("../../test/support/images/rails.png") }
    }
    assert_redirected_to new_user_session_url
  end

  test "should destroy image as admin" do
    login(users(:admin))
    assert_difference("Image.count", -1) do
      delete image_url(images(:three))
    end
    assert_redirected_to images_url
  end

  test "should not destroy image as regular user" do
    login(users(:valid))
    assert_difference("Image.count", 0) do
      delete image_url(images(:three))
    end
    assert_redirected_to root_url
  end

  test "should not destroy image as public user" do
    assert_difference("Image.count", 0) do
      delete image_url(images(:three))
    end
    assert_redirected_to new_user_session_url
  end
end

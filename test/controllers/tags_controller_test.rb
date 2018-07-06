# frozen_string_literal: true

require "test_helper"

# Allows admin to edit forum and data request tags.
class TagsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @tag = tags(:meeting)
    @admin = users(:admin)
  end

  test "should get index" do
    login(@admin)
    get tags_url
    assert_response :success
    assert_not_nil assigns(:tags)
  end

  test "should get new" do
    login(@admin)
    get new_tag_url
    assert_response :success
  end

  test "should create tag" do
    login(@admin)
    assert_difference("Tag.count") do
      post tags_url, params: { tag: { name: "Blog", color: @tag.color, tag_type: "topic" } }
    end
    assert_redirected_to tag_url(Tag.last)
  end

  test "should not create tag with non-unique name" do
    login(@admin)
    assert_difference("Tag.count", 0) do
      post tags_url, params: { tag: { name: "Meeting", color: @tag.color, tag_type: "topic" } }
    end
    assert_not_nil assigns(:tag)
    assert_equal ["has already been taken"], assigns(:tag).errors[:name]
    assert_template "new"
    assert_response :success
  end

  test "should show tag" do
    login(@admin)
    get tag_url(@tag)
    assert_response :success
  end

  test "should get edit" do
    login(@admin)
    get edit_tag_url(@tag)
    assert_response :success
  end

  test "should update tag" do
    login(@admin)
    patch tag_url(@tag), params: { tag: { name: "Meetings", color: @tag.color, tag_type: "topic" } }
    assert_redirected_to tag_url(@tag)
  end

  test "should not update tag with blank name" do
    login(@admin)
    patch tag_url(@tag), params: { tag: { name: "", color: @tag.color, tag_type: "topic" } }
    assert_not_nil assigns(:tag)
    assert_equal ["can't be blank"], assigns(:tag).errors[:name]
    assert_template "edit"
    assert_response :success
  end

  test "should destroy tag" do
    login(@admin)
    assert_difference("Tag.current.count", -1) do
      delete tag_url(@tag)
    end
    assert_redirected_to tags_url
  end
end

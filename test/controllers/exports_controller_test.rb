# frozen_string_literal: true

require "test_helper"

# Test to show if exports can be viewed and downloaded.
class ExportsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @export = exports(:one)
    @admin = users(:admin)
  end

  def export_params
    {
      name: @export.name,
      organization_id: @admin.organizations.first.id
    }
  end

  test "should get index" do
    login(@admin)
    get exports_url
    assert_response :success
  end

  test "should get new" do
    login(@admin)
    get new_export_url
    assert_response :success
  end

  test "should create export" do
    login(@admin)
    assert_difference("Export.count") do
      post exports_url, params: { export: export_params }
    end
    assert_redirected_to export_url(Export.last)
  end

  test "should show export" do
    login(@admin)
    get export_url(@export)
    assert_response :success
  end

  test "should show progress" do
    login(@admin)
    post progress_export_url(@export, format: "js")
    assert_template "progress"
    assert_response :success
  end

  test "should download export" do
    login(@admin)
    get download_export_url(@export)
    assert_equal File.binread(@export.zipped_file.path), response.body
    assert_response :success
  end

  test "should get edit" do
    login(@admin)
    get edit_export_url(@export)
    assert_response :success
  end

  test "should update export" do
    login(@admin)
    patch export_url(@export), params: { export: export_params }
    assert_redirected_to export_url(@export)
  end

  test "should destroy export" do
    login(@admin)
    assert_difference("Export.current.count", -1) do
      delete export_url(exports(:two))
    end
    assert_redirected_to exports_url
  end
end

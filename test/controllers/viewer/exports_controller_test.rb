# frozen_string_literal: true

require "test_helper"

# Test to show if exports can be viewed and downloaded.
class Viewer::ExportsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @export = exports(:one)
    @organization = organizations(:one)
    @org_editor = users(:editor)
    @org_viewer = users(:orgone_viewer)
    @regular = users(:regular)
  end

  test "should get index as editor" do
    login(@org_editor)
    get organization_exports_url(@organization)
    assert_response :success
  end

  test "should not get index as regular" do
    login(@regular)
    get organization_exports_url(@organization)
    assert_redirected_to organizations_url
  end

  test "should create export as editor" do
    login(@org_editor)
    assert_difference("Export.count") do
      post organization_exports_url(@organization)
    end
    assert_redirected_to organization_export_url(Export.last.organization, Export.last)
  end

  test "should not create export as regular" do
    login(@regular)
    assert_difference("Export.count", 0) do
      post organization_exports_url(@organization)
    end
    assert_redirected_to organizations_url
  end

  test "should show export as editor" do
    login(@org_editor)
    get organization_export_url(@organization, @export)
    assert_response :success
  end

  test "should show progress as editor" do
    login(@org_editor)
    post progress_organization_export_url(@organization, @export, format: "js")
    assert_template "viewer/exports/progress"
    assert_response :success
  end

  test "should download export as editor" do
    login(@org_editor)
    get download_organization_export_url(@organization, @export)
    assert_equal File.binread(@export.zipped_file.path), response.body
    assert_response :success
  end

  test "should destroy export as editor" do
    login(@org_editor)
    assert_difference("Export.current.count", -1) do
      delete organization_export_url(exports(:two).organization, exports(:two))
    end
    assert_redirected_to organization_exports_url(exports(:two).organization)
  end
end

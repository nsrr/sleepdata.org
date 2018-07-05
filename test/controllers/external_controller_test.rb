# frozen_string_literal: true

require "test_helper"

SimpleCov.command_name "test:controllers"

# Tests to assure public pages are displayed correctly.
class ExternalControllerTest < ActionDispatch::IntegrationTest
  test "should get about" do
    get about_url
    assert_response :success
  end

  test "should get aug" do
    get aug_url
    assert_response :success
  end

  test "should get contact" do
    get contact_url
    assert_response :success
  end

  test "should get contributors" do
    get contributors_url
    assert_response :success
  end

  test "should get landing" do
    get landing_url
    assert_response :success
  end

  test "should get privacy policy" do
    get privacy_policy_url
    assert_response :success
  end

  test "should get sitemap" do
    get sitemap_url
    assert_response :success
  end

  test "should get sitemap xml file" do
    get sitemap_xml_url
    assert_response :success
  end

  test "should get team" do
    get team_url
    assert_response :success
  end

  test "should get share" do
    get share_url
    assert_response :success
  end

  test "should get fair" do
    get fair_url
    assert_response :success
  end

  test "should get data sharing language" do
    get datasharing_url
    assert_response :success
  end

  test "should get demo for public user" do
    get demo_url
    assert_response :success
  end

  test "should get version" do
    get version_url
    assert_response :success
  end

  test "should get version as json" do
    get version_url(format: "json")
    version = JSON.parse(response.body)
    assert_equal SleepData::VERSION::STRING, version["version"]["string"]
    assert_equal SleepData::VERSION::MAJOR, version["version"]["major"]
    assert_equal SleepData::VERSION::MINOR, version["version"]["minor"]
    assert_equal SleepData::VERSION::TINY, version["version"]["tiny"]
    if SleepData::VERSION::BUILD.nil?
      assert_nil version["version"]["build"]
    else
      assert_equal SleepData::VERSION::BUILD, version["version"]["build"]
    end
    assert_response :success
  end

  test "should get voting" do
    get voting_url
    assert_response :success
  end
end

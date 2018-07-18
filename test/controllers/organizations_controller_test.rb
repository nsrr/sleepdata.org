# frozen_string_literal: true

require "test_helper"

# Allows admins to create organizations and assign users as owners.
class OrganizationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @organization = organizations(:one)
    @regular = users(:regular)
  end

  test "should get index as regular" do
    login(@regular)
    get organizations_url
    assert_response :success
  end

  test "should get index as public" do
    get organizations_url
    assert_response :success
  end

  test "should show organization as regular" do
    login(@regular)
    get organization_url(@organization)
    assert_response :success
  end

  test "should show organization as public" do
    get organization_url(@organization)
    assert_response :success
  end
end

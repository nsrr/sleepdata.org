# frozen_string_literal: true

require "test_helper"

# Test to check domain API.
class Api::V1::DomainsControllerTest < ActionDispatch::IntegrationTest
  # setup do
  #   @domain = domains(:one)
  # end

  # test "should get index" do
  #   get api_v1_domains_url
  #   assert_response :success
  #   assert_not_nil assigns(:domains)
  # end

  # test "should get new" do
  #   get new_api_v1_domain_url
  #   assert_response :success
  # end

  # test "should create domain" do
  #   assert_difference("Domain.count") do
  #     post api_v1_domains_url, domain: { create: @domain.create, name: @domain.name }
  #   end

  #   assert_redirected_to domain_url(Domain.first)
  # end

  # test "should show domain" do
  #   get api_v1_domain_url(@domain)
  #   assert_response :success
  # end

  # test "should get edit" do
  #   get edit_api_v1_domain_url(@domain)
  #   assert_response :success
  # end

  # test "should update domain" do
  #   patch api_v1_domain_url(@domain), params: { domain: { create: @domain.create, name: @domain.name } }
  #   assert_redirected_to domain_url(assigns(:domain))
  # end

  # test "should destroy domain" do
  #   assert_difference("Domain.count", -1) do
  #     delete api_v1_domain_url(@domain)
  #   end
  #   assert_redirected_to domains_url
  # end
end

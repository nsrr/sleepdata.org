require 'test_helper'

class Api::V1::DomainsControllerTest < ActionController::TestCase
  setup do
    @domain = domains(:one)
  end

  test 'should get index' do
    skip
    get :index
    assert_response :success
    assert_not_nil assigns(:domains)
  end

  test 'should get new' do
    skip
    get :new
    assert_response :success
  end

  test 'should create domain' do
    skip
    assert_difference('Domain.count') do
      post :create, domain: { create: @domain.create, name: @domain.name }
    end

    assert_redirected_to domain_path(assigns(:domain))
  end

  test 'should show domain' do
    skip
    get :show, id: @domain
    assert_response :success
  end

  test 'should get edit' do
    skip
    get :edit, id: @domain
    assert_response :success
  end

  test 'should update domain' do
    skip
    patch :update, id: @domain, domain: { create: @domain.create, name: @domain.name }
    assert_redirected_to domain_path(assigns(:domain))
  end

  test 'should destroy domain' do
    skip
    assert_difference('Api::V1::Domain.count', -1) do
      delete :destroy, id: @domain
    end

    assert_redirected_to domains_path
  end
end

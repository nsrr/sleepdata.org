# frozen_string_literal: true

require 'test_helper'

SimpleCov.command_name 'test:integration'

# Tests to assure that user navigation is working as intended
class NavigationTest < ActionDispatch::IntegrationTest
  fixtures :users

  def setup
    @valid = users(:valid)
    @deleted = users(:deleted)
  end

  test 'should get root path' do
    get '/'
    assert_equal '/', path
  end

  test 'should get sign up page' do
    get new_user_registration_path
    assert_equal new_user_registration_path, path
    assert_response :success
  end

  test 'should register new account' do
    post user_registration_path, params: {
      user: {
        first_name: 'register', last_name: 'account',
        email: 'register@account.com', password: 'registerpassword098765',
        password_confirmation: 'registerpassword098765', emails_enabled: '1'
      }
    }
    assert_equal I18n.t('devise.registrations.signed_up'), flash[:notice]
    assert_redirected_to root_path
  end

  test 'deleted users should be not be allowed to login' do
    get new_user_session_path

    sign_in_as(@deleted, '123456')
    assert_equal new_user_session_path, path
    assert_equal I18n.t('devise.failure.inactive'), flash[:alert]
  end

  test 'friendly url forwarding after login' do
    get datasets_path
    get new_user_session_path

    sign_in_as(@valid, '123456')
    assert_equal datasets_path, path
    assert_equal I18n.t('devise.sessions.signed_in'), flash[:notice]
  end

  test 'friendly url forwarding after logout' do
    get datasets_path
    sign_in_as(@valid, '123456')

    get datasets_path
    get destroy_user_session_path

    assert_redirected_to datasets_path
    assert_equal I18n.t('devise.sessions.signed_out'), flash[:notice]
  end

  test 'blog rss should not be stored in friendly forwarding after login' do
    get blog_path(format: 'atom')
    get new_user_session_path
    sign_in_as(@valid, '123456')
    assert_equal root_path, path
    assert_equal I18n.t('devise.sessions.signed_in'), flash[:notice]
  end
end

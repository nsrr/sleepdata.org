require 'test_helper'

class BroadcastsControllerTest < ActionController::TestCase
  setup do
    @broadcast = broadcasts(:draft)
    login(users(:community_manager))
  end

  test 'should get index' do
    get :index
    assert_response :success
    assert_not_nil assigns(:broadcasts)
  end

  test 'should get new' do
    get :new
    assert_response :success
  end

  test 'should create broadcast' do
    assert_difference('Broadcast.count') do
      post :create, params: { broadcast: { title: 'Broadcast Title', short_description: 'This is the short description.',  description: 'This is the longer content of the blog post.', pinned: '1', publish_date: '11/15/2015', published: '1', archived: '0' } }
    end

    assert_not_nil assigns(:broadcast)
    assert_equal 'Broadcast Title', assigns(:broadcast).title
    assert_equal 'This is the short description.', assigns(:broadcast).short_description
    assert_equal 'This is the longer content of the blog post.', assigns(:broadcast).description
    assert_equal users(:community_manager), assigns(:broadcast).user
    assert_equal true, assigns(:broadcast).pinned
    assert_equal true, assigns(:broadcast).published
    assert_equal false, assigns(:broadcast).archived

    assert_redirected_to broadcast_path(assigns(:broadcast))
  end

  test 'should show broadcast' do
    get :show, params: { id: @broadcast }
    assert_response :success
  end

  test 'should get edit' do
    get :edit, params: { id: @broadcast }
    assert_response :success
  end

  test 'should update broadcast' do
    patch :update, params: { id: @broadcast, broadcast: { archived: @broadcast.archived, title: @broadcast.title, short_description: @broadcast.short_description,  description: @broadcast.description, pinned: @broadcast.pinned, publish_date: '11/15/2015', published: @broadcast.published } }
    assert_redirected_to broadcast_path(assigns(:broadcast))
  end

  test 'should destroy broadcast' do
    assert_difference('Broadcast.current.count', -1) do
      delete :destroy, params: { id: @broadcast }
    end

    assert_redirected_to broadcasts_path
  end
end

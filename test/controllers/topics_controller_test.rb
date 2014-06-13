require 'test_helper'

class TopicsControllerTest < ActionController::TestCase
  setup do
    @topic = topics(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:topics)
  end

  test "should get new" do
    login(users(:valid))
    get :new
    assert_response :success
  end

  test "should create topic" do
    login(users(:valid))
    assert_difference('Comment.count') do
      assert_difference('Topic.count') do
        post :create, topic: { name: "New Topic Name", description: "First Comment on New Topic" }
      end
    end

    assert_not_nil assigns(:topic)
    assert_equal "New Topic Name", assigns(:topic).name
    assert_equal users(:valid), assigns(:topic).user
    assert_equal "First Comment on New Topic", assigns(:topic).comments.first.description
    assert_equal users(:valid), assigns(:topic).comments.first.user

    assert_redirected_to topic_path(assigns(:topic))
  end

  test "should not create topic with blank description" do
    login(users(:valid))
    assert_difference('Comment.count', 0) do
      assert_difference('Topic.count', 0) do
        post :create, topic: { name: "New Topic Name", description: "" }
      end
    end

    assert_not_nil assigns(:topic)
    assert assigns(:topic).errors.size > 0
    assert_equal ["can't be blank"], assigns(:topic).errors[:description]

    assert_template 'new'
  end

  test "should not create topic when user exceeds two topics per day" do
    login(users(:valid))
    topic_one = users(:valid).topics.create(name: "Topic One", description: "First Topic of the Day")
    topic_two = users(:valid).topics.create(name: "Topic Two", description: "Second Topic of the Day")

    assert_difference('Comment.count', 0) do
      assert_difference('Topic.count', 0) do
        post :create, topic: { name: "Third topic of the day", description: "Spamming Topics" }
      end
    end

    assert_nil assigns(:topic)
    assert_equal "You have exceeded your maximum topics created per day.", flash[:warning]

    assert_redirected_to topics_path
  end

  test "should not create topic as banned user" do
    login(users(:banned))
    assert_difference('Comment.count', 0) do
      assert_difference('Topic.count', 0) do
        post :create, topic: { name: "I'm trying to post a topic", description: "Visit my site with advertisements." }
      end
    end

    assert_nil assigns(:topic)
    assert_equal "You do not have permission to post on the forum.", flash[:warning]

    assert_redirected_to topics_path
  end

  test "should show topic" do
    get :show, id: @topic
    assert_response :success
  end

  test "should not show topic from banned user" do
    get :show, id: topics(:banned)

    assert_nil assigns(:topic)
    assert_redirected_to topics_path
  end

  test "should get edit" do
    login(users(:valid))
    get :edit, id: @topic
    assert_response :success
  end

  test "should not get edit as another user" do
    login(users(:two))
    get :edit, id: @topic

    assert_nil assigns(:topic)
    assert_redirected_to topics_path
  end

  test "should not get edit for locked topic" do
    login(users(:valid))
    get :edit, id: topics(:locked)

    assert_nil assigns(:topic)

    assert_redirected_to topics_path
  end

  test "should not get edit for banned user" do
    login(users(:banned))
    get :edit, id: topics(:banned)

    assert_nil assigns(:topic)

    assert_redirected_to topics_path
  end

  test "should update topic" do
    login(users(:valid))
    patch :update, id: @topic, topic: { name: "Updated Topic Name" }

    assert_not_nil assigns(:topic)
    assert_equal "Updated Topic Name", assigns(:topic).name

    assert_redirected_to topic_path(assigns(:topic))
  end

  test "should not update topic as another user" do
    login(users(:two))
    patch :update, id: @topic, topic: { name: "Updated Topic Name" }

    assert_nil assigns(:topic)

    assert_redirected_to topics_path
  end

  test "should not update topic as banned user" do
    login(users(:banned))
    patch :update, id: topics(:banned), topic: { name: "Updated Banned Topic Name" }

    assert_nil assigns(:topic)

    assert_redirected_to topics_path
  end

  test "should lock topic as a system admin" do
    login(users(:admin))
    post :admin, id: @topic, topic: { locked: '1' }

    assert_not_nil assigns(:topic)
    assert_equal true, assigns(:topic).locked

    assert_redirected_to topics_path
  end

  test "should not lock topic as a regular user" do
    login(users(:valid))
    post :admin, id: @topic, topic: { locked: '1' }

    assert_nil assigns(:topic)

    assert_redirected_to root_path
  end

  test "should not lock topic as an anonymous user" do
    post :admin, id: @topic, topic: { locked: '1' }

    assert_nil assigns(:topic)
    assert_redirected_to new_user_session_path
  end

  test "should sticky a topic as a system admin" do
    login(users(:admin))
    post :admin, id: @topic, topic: { stickied: '1' }

    assert_not_nil assigns(:topic)
    assert_equal true, assigns(:topic).stickied

    assert_redirected_to topics_path
  end

  test "should not sticky a topic as a regular user" do
    login(users(:valid))
    post :admin, id: @topic, topic: { stickied: '1' }

    assert_nil assigns(:topic)
    assert_redirected_to root_path
  end

  test "should not sticky topic as an anonymous user" do
    post :admin, id: @topic, topic: { stickied: '1' }

    assert_nil assigns(:topic)
    assert_redirected_to new_user_session_path
  end

  test "should not destroy topic as user" do
    login(users(:valid))
    assert_difference('Topic.current.count', 0) do
      delete :destroy, id: @topic
    end

    assert_redirected_to root_path
  end

  test "should destroy topic as admin" do
    login(users(:admin))
    assert_difference('Topic.current.count', -1) do
      delete :destroy, id: @topic
    end

    assert_redirected_to topics_path
  end
end

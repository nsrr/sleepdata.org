# frozen_string_literal: true

require 'test_helper'

# Topic unit tests
class TopicTest < ActiveSupport::TestCase
  def topic_params
    {
      user_id: User.first.id,
      title: 'Topic Title',
      slug: 'topic-title',
      description: 'First Reply'
    }
  end

  test 'should save topic' do
    topic = Topic.new(topic_params)
    assert_difference('Reply.count') do
      assert_difference('Topic.count') do
        topic.save
      end
    end
    assert_equal 0, topic.errors.count
    assert_equal 'Topic Title', topic.title
    assert_equal User.first.id, topic.user.id
    assert_equal 'First Reply', topic.replies.first.description
    assert_equal User.first.id, topic.replies.first.user_id
  end

  test 'should not save topic with blank title' do
    topic = Topic.new(topic_params.merge(title: ''))
    assert_difference('Reply.count', 0) do
      assert_difference('Topic.count', 0) do
        topic.save
      end
    end
    assert_equal 1, topic.errors.count
    assert_equal ["can't be blank"], topic.errors[:title]
  end

  test 'should not save topic without user' do
    topic = Topic.new(topic_params.merge(user_id: nil))
    assert_difference('Reply.count', 0) do
      assert_difference('Topic.count', 0) do
        topic.save
      end
    end
    assert_equal 1, topic.errors.count
    assert_equal ["can't be blank"], topic.errors[:user_id]
  end

  test 'should not save topic without description' do
    topic = Topic.new(topic_params.merge(description: ''))
    assert_difference('Reply.count', 0) do
      assert_difference('Topic.count', 0) do
        topic.save
      end
    end
    assert_equal 1, topic.errors.count
    assert_equal ["can't be blank"], topic.errors[:description]
  end
end

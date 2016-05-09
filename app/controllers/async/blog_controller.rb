# frozen_string_literal: true

# Provides methods to login and register while creating a blog post comment.
class Async::BlogController < Async::BaseController
  before_action :set_broadcast,         only: [:login, :reply]
  before_action :set_broadcast_comment, only: [:login, :reply]

  def login
    super
    if current_user
      render :create
    else
      render :new
    end
  end

  def register
    super
    render text: 'register'
  end

  def reply
  end

  private

  def set_broadcast
    @broadcast = Broadcast.current.published.find_by_slug params[:broadcast_id]
  end

  def set_broadcast_comment
    @broadcast_comment = @broadcast.broadcast_comments.find_by_id params[:broadcast_comment_id]
    unless @broadcast_comment
      @broadcast_comment = @broadcast.broadcast_comments.new(
        broadcast_comment_id: params[:parent_comment_id] == 'root' ? nil : params[:parent_comment_id]
      )
    end
  end
end

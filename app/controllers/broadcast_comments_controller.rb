# frozen_string_literal: true

# Allows users to discuss a blog post.
class BroadcastCommentsController < ApplicationController
  before_action :authenticate_user!, except: [:vote]
  before_action :find_broadcast_or_redirect, except: [:preview]
  before_action :find_broadcast_comment_or_redirect, only: [:show, :edit, :update, :destroy]

  # # GET /broadcast_comments
  # def index
  #   @broadcast_comments = BroadcastComment.all
  # end

  # # GET /broadcast_comments/1
  # def show
  # end

  def preview
    @broadcast_comment = current_user.broadcast_comments.new(broadcast_comment_params)
  end

  def vote
    @broadcast_comment = @broadcast.broadcast_comments.find_by_id params[:id]
    redirect_without_broadcast_comment
    if current_user
      @broadcast_comment_user = @broadcast.broadcast_comment_users.where(
        user_id: current_user.id, broadcast_comment: @broadcast_comment.id
      ).first_or_create
      case params[:vote]
      when 'up'
        @broadcast_comment_user.up_vote!
      when 'down'
        @broadcast_comment_user.down_vote!
      else
        @broadcast_comment_user.remove_vote!
      end
    end
  end

  # # GET /broadcast_comments/new
  # def new
  #   @broadcast_comment = BroadcastComment.new
  # end

  # GET /broadcast_comments/1/edit.js
  def edit
  end

  # POST /broadcast_comments
  def create
    @broadcast_comment = current_user.broadcast_comments.where(broadcast_id: @broadcast.id)
                                     .new(broadcast_comment_params)
    if @broadcast_comment.save
      render :create
    else
      render :new
    end
  end

  # PATCH /broadcast_comments/1
  def update
    if @broadcast_comment.update(broadcast_comment_params)
      render :show
    else
      render :edit
    end
  end

  # DELETE /broadcast_comments/1
  def destroy
    @broadcast_comment.destroy
    render :show
  end

  private

  def find_broadcast_or_redirect
    @broadcast = Broadcast.current.published.find_by_slug params[:broadcast_id]
    redirect_without_broadcast
  end

  def redirect_without_broadcast
    empty_response_or_root_path(blog_path) unless @broadcast
  end

  def find_broadcast_comment_or_redirect
    @broadcast_comment = current_user.editable_broadcast_comments.where(broadcast_id: @broadcast.id).find_by_id params[:id]
    redirect_without_broadcast_comment
  end

  def redirect_without_broadcast_comment
    empty_response_or_root_path(blog_post_path(@broadcast.url_hash)) unless @broadcast_comment
  end

  def broadcast_comment_params
    params.require(:broadcast_comment).permit(:description, :broadcast_comment_id)
  end
end

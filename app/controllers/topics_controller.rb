# frozen_string_literal: true

# Allows users to view and create topics on the forum
class TopicsController < ApplicationController
  before_action :authenticate_user!, only: [:new, :create, :edit, :update, :destroy, :admin, :subscription]
  before_action :check_system_admin, only: [:destroy, :admin]
  before_action :check_banned, only: [:create, :edit, :update]
  before_action :check_max_topics_per_day_reached, only: [:create]
  before_action :find_viewable_topic_or_redirect, only: [:show, :destroy, :admin, :subscription]
  before_action :find_editable_topic_or_redirect, only: [:edit, :update]

  def markup
  end

  # POST /forum/1-my-first-topic/subscription.js
  def subscription
    @topic.set_subscription!(params[:notify].to_s == '1', current_user)
  end

  # POST /forum/1-my-first-topic/admin
  def admin
    @topic.update(topic_admin_params)
    redirect_to topics_path
  end

  # GET /forum
  def index
    topic_scope = Topic.current.not_banned.search(params[:s])
    user_ids = User.current.with_name(params[:a].to_s.split(','))
    topic_scope = topic_scope.where(user_id: user_ids) unless params[:a].blank?
    @topics = topic_scope.order(stickied: :desc, last_comment_at: :desc).page(params[:page]).per(50)
  end

  # GET /forum/1-my-first-topic
  def show
    @comments = @topic.comments.order(:id).page(params[:page]).per(Comment::COMMENTS_PER_PAGE)
  end

  # GET /forum/new
  def new
    @topic = Topic.new
  end

  # GET /forum/1-my-first-topic/edit
  def edit
  end

  # POST /forum
  def create
    @topic = current_user.topics.new(topic_params)

    if @topic.save
      @topic.update_column :last_comment_at, Time.zone.now
      redirect_to @topic, notice: 'Topic was successfully created.'
    else
      render :new
    end
  end

  # PATCH /forum/1-my-first-topic
  def update
    if @topic.update(topic_params)
      redirect_to @topic, notice: 'Topic was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /forum/1-my-first-topic
  def destroy
    @topic.destroy
    redirect_to topics_path
  end

  private

  def find_viewable_topic_or_redirect
    @topic = Topic.current.not_banned.find_by_id params[:id]
    redirect_without_topic
  end

  def find_editable_topic_or_redirect
    @topic = current_user.all_topics.not_banned.where(locked: false).find_by_id params[:id]
    redirect_without_topic
  end

  def redirect_without_topic
    empty_response_or_root_path(topics_path) unless @topic
  end

  def check_max_topics_per_day_reached
    if current_user.topics_created_in_last_day.count >= current_user.max_topics
      flash[:warning] = 'You have exceeded your maximum topics created per day.'
      redirect_to topics_path
    end
  end

  def topic_params
    if current_user.aug_member? || current_user.core_member?
      params.require(:topic).permit(:name, :description, tag_ids: [])
    else
      params.require(:topic).permit(:name, :description)
    end
  end

  def topic_admin_params
    params.require(:topic).permit(:locked, :stickied)
  end
end

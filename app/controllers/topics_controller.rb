# frozen_string_literal: true

# Allows users to view and create topics on the forum
class TopicsController < ApplicationController
  before_action :authenticate_user!, only: [:new, :create, :edit, :update, :destroy, :admin, :subscription]
  before_action :check_system_admin, only: [:destroy, :admin]
  before_action :check_banned, only: [:create, :edit, :update]
  before_action :find_viewable_topic_or_redirect, only: [:show, :destroy, :admin, :subscription]
  before_action :find_editable_topic_or_redirect, only: [:edit, :update]

  def markup
  end

  # POST /forum/my-first-topic/subscription.js
  def subscription
    @topic.set_subscription!(params[:notify].to_s == "1", current_user)
  end

  # POST /forum/my-first-topic/admin
  def admin
    @topic.update(topic_admin_params)
    redirect_to topics_path
  end

  # GET /forum
  def index
    @order = scrub_order(Topic, params[:order], "pinned desc, last_reply_at desc, id desc")
    if ["reply_count", "reply_count desc"].include?(params[:order])
      @order = params[:order]
    end
    topic_scope = Topic.current.not_banned
    @topics = topic_scope.reply_count.order(@order).page(params[:page]).per(40)
  end

  # GET /forum/my-first-topic
  def show
    @page = (params[:page].to_i > 1 ? params[:page].to_i : 1)
    @replies = @topic.replies.includes(:topic).where(reply_id: nil).page(@page).per(Reply::REPLIES_PER_PAGE)
    @topic.increment! :view_count
    current_user.read_parent!(@topic, @replies.last.id) if current_user
  end

  # GET /forum/new
  def new
    @topic = current_user.topics.new
  end

  # GET /forum/my-first-topic/edit
  def edit
  end

  # POST /forum
  def create
    @topic = current_user.topics.new(topic_params)

    if @topic.save
      # @topic.update_column :last_reply_at, Time.zone.now
      @topic.touch :last_reply_at
      redirect_to @topic, notice: "Topic was successfully created."
    else
      render :new
    end
  end

  # PATCH /forum/my-first-topic
  def update
    if @topic.update(topic_params)
      redirect_to @topic, notice: "Topic was successfully updated."
    else
      render :edit
    end
  end

  # DELETE /forum/my-first-topic
  def destroy
    @topic.destroy
    redirect_to topics_path, notice: "Topic was successfully deleted."
  end

  private

  def viewable_topics
    Topic.current.not_banned
  end

  def find_viewable_topic_or_redirect
    @topic = viewable_topics.find_by_param(params[:id])
    redirect_without_topic
  end

  def find_editable_topic_or_redirect
    @topic = current_user.all_topics.not_banned.where(locked: false).find_by_param(params[:id])
    redirect_without_topic
  end

  def redirect_without_topic
    empty_response_or_root_path topics_path unless @topic
  end

  def topic_params
    if current_user.system_admin?
      params.require(:topic).permit(:title, :slug, :description, :pinned, :locked, tag_ids: [])
    elsif current_user.aug_member? || current_user.core_member?
      params.require(:topic).permit(:title, :slug, :description, tag_ids: [])
    else
      params.require(:topic).permit(:title, :slug, :description)
    end
  end

  def topic_admin_params
    params.require(:topic).permit(:locked, :pinned)
  end
end

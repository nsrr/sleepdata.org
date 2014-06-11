class TopicsController < ApplicationController
  before_action :authenticate_user!, only: [ :new, :create, :edit, :update, :destroy ]
  before_action :check_system_admin, only: [ :destroy ]
  before_action :check_max_topics_per_day_reached, only: [ :create ]
  before_action :set_viewable_topic, only: [ :show, :destroy ]
  before_action :set_editable_topic, only: [ :edit, :update ]
  before_action :redirect_without_topic, only: [ :show, :edit, :update, :destroy ]

  # GET /topics
  # GET /topics.json
  def index
    topic_scope = Topic.current.search(params[:s])
    user_ids = User.current.with_name(params[:a].to_s.split(','))
    topic_scope = topic_scope.where( user_id: user_ids ) unless params[:a].blank?
    @topics = topic_scope.order(stickied: :desc, id: :desc).page(params[:page]).per( 50 )
  end

  # GET /topics/1
  # GET /topics/1.json
  def show
    @comment = @topic.comments.new
    @comments = @topic.comments.order(:id).page(params[:page]).per( 50 )
  end

  # GET /topics/new
  def new
    @topic = Topic.new
  end

  # GET /topics/1/edit
  def edit
  end

  # POST /topics
  # POST /topics.json
  def create
    @topic = current_user.topics.new(topic_params)

    respond_to do |format|
      if @topic.save
        format.html { redirect_to @topic, notice: 'Topic was successfully created.' }
        format.json { render action: 'show', status: :created, location: @topic }
      else
        format.html { render action: 'new' }
        format.json { render json: @topic.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /topics/1
  # PUT /topics/1.json
  def update
    respond_to do |format|
      if @topic.update(topic_params)
        format.html { redirect_to @topic, notice: 'Topic was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @topic.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /topics/1
  # DELETE /topics/1.json
  def destroy
    @topic.destroy

    respond_to do |format|
      format.html { redirect_to topics_path }
      format.json { head :no_content }
    end
  end

  private
    def set_viewable_topic
      @topic = Topic.current.find_by_id(params[:id])
    end

    def set_editable_topic
      @topic = current_user.all_topics.where( locked: false ).find_by_id(params[:id])
    end

    def check_max_topics_per_day_reached
      if current_user.topics_created_in_last_day.count >= current_user.max_topics
        flash[:warning] = "You have exceeded your maximum topics created per day."
        redirect_to topics_path
      end
    end

    def topic_params
      params.require(:topic).permit(:name, :description)
    end

    def redirect_without_topic
      empty_response_or_root_path( topics_path ) unless @topic
    end

end

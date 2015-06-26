class CommentsController < ApplicationController
  before_action :authenticate_user!, only: [ :new, :create, :edit, :update, :destroy, :preview ]
  before_action :set_topic, only: [ :show, :destroy ]
  before_action :set_commentable_topic, only: [ :create, :edit, :update, :preview ]
  before_action :redirect_without_topic, only: [ :show, :create, :edit, :update, :preview, :destroy ]

  before_action :check_banned, only: [ :create, :edit, :update ]
  before_action :set_comment, only: [ :show ]
  before_action :set_editable_comment, only: [ :edit, :update ]
  before_action :set_deletable_comment, only: [ :destroy ]
  before_action :redirect_without_comment, only: [ :show, :edit, :update, :destroy ]


  # # GET /comments
  # # GET /comments.json
  # def index
  #   @order = "comments.id"
  #   @comments = Comment.current.order(@order).page(params[:page]).per( 40 )
  # end

  # # GET /comments/new
  # def new
  #   @comment = Comment.new
  # end

  # GET /comments/1/edit
  def edit
  end

  # POST /comments
  # POST /comments.json
  def create
    @comment = current_user.comments.where(topic_id: @topic.id).new(comment_params)

    respond_to do |format|
      if @comment.save
        @comment.send_reply_emails!
        @topic.get_or_create_subscription(current_user)
        format.html { redirect_to topic_comment_path(@topic, @comment), notice: 'Comment was successfully created.' }
        format.json { render action: 'show', status: :created, location: @comment }
      else
        format.html { redirect_to topic_path(@topic, error: @errors) }
        format.json { render json: @comment.errors, status: :unprocessable_entity }
      end
    end
  end

  def preview
    if @comment = @topic.comments.find_by_id(params[:comment_id])
      @comment.description = params[:comment][:description]
    else
      @comment = @topic.comments.new(comment_params)
      @comment.user_id = current_user.id
    end
  end

  def show
    respond_to do |format|
      format.html { redirect_to topic_path(@topic) + "?page=#{((@comment.number - 1) / Comment::COMMENTS_PER_PAGE)+1}#c#{@comment.number}" }
      format.js
    end
  end

  # def show
  # end

  # PUT /comments/1
  # PUT /comments/1.json
  def update
    respond_to do |format|
      if @comment.update(comment_params)
        format.html { redirect_to topic_comment_path(@topic, @comment), notice: 'Comment was successfully updated.' }
        format.json { head :no_content }
        format.js { render 'show' }
      else
        format.html { redirect_to topic_comment_path(@topic, @comment), warning: 'Comment can\'t be blank.' }
        format.json { render json: @comment.errors, status: :unprocessable_entity }
        format.js { render 'edit' }
      end
    end
  end

  # DELETE /comments/1
  # DELETE /comments/1.json
  def destroy
    @comment.destroy

    respond_to do |format|
      format.html { redirect_to topic_comment_path(@topic, @comment) }
      format.json { head :no_content }
    end
  end

  private
    def set_topic
      @topic = Topic.current.find_by_id(params[:topic_id])
    end

    def set_commentable_topic
      @topic = Topic.current.where( locked: false ).find_by_id(params[:topic_id])
    end

    def redirect_without_topic
      empty_response_or_root_path( topics_path ) unless @topic
    end

    def set_comment
      @comment = Comment.current.find_by_id(params[:id])
    end

    def set_editable_comment
      @comment = current_user.all_comments.with_unlocked_topic.find_by_id(params[:id])
    end

    def set_deletable_comment
      @comment = current_user.all_comments.find_by_id(params[:id])
    end

    def redirect_without_comment
      empty_response_or_root_path( topics_path ) unless @comment
    end

    def comment_params
      params.require(:comment).permit(:description)
    end
end

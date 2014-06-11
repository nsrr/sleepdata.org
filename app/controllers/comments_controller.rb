class CommentsController < ApplicationController
  before_action :authenticate_user!, only: [ :new, :create, :edit, :update, :destroy ]
  before_action :set_comment, only: [ :show, :edit, :update, :destroy ]
  before_action :set_topic, only: [ :create ]
  before_action :redirect_without_topic, only: [ :create ]


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

  # # GET /comments/1/edit
  # def edit
  # end

  # POST /comments
  # POST /comments.json
  def create
    @comment = @topic.comments.new(comment_params)

    respond_to do |format|
      if @comment.save
        format.html { redirect_to @topic, notice: 'Comment was successfully created.' }
        format.json { render action: 'show', status: :created, location: @comment }
      else
        format.html { redirect_to topic_path(@topic, error: @errors) }
        format.json { render json: @comment.errors, status: :unprocessable_entity }
      end
    end
  end

  # # PUT /comments/1
  # # PUT /comments/1.json
  # def update
  #   respond_to do |format|
  #     if @comment.update(comment_params)
  #       format.html { redirect_to @comment, notice: 'Comment was successfully updated.' }
  #       format.json { head :no_content }
  #     else
  #       format.html { render action: 'edit' }
  #       format.json { render json: @comment.errors, status: :unprocessable_entity }
  #     end
  #   end
  # end

  # # DELETE /comments/1
  # # DELETE /comments/1.json
  # def destroy
  #   @comment.destroy

  #   respond_to do |format|
  #     format.html { redirect_to comments_path }
  #     format.json { head :no_content }
  #   end
  # end

  private
    def set_topic
      @topic = Topic.current.find_by_id(params[:topic_id])
    end

    def redirect_without_topic
      empty_response_or_root_path( topics_path ) unless @topic
    end

    def set_comment
      @comment = Comment.current.find(params[:id])
    end

    def comment_params
      params[:comment] ||= { }
      params[:comment][:user_id] = current_user.id unless @comment

      params.require(:comment).permit(:description, :user_id)
    end
end

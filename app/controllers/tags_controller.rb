class TagsController < ApplicationController
  respond_to :html, :json

  before_action :authenticate_user!
  before_action :check_system_admin
  before_action :set_tag,               only: [:show, :edit, :update, :destroy]
  before_action :redirect_without_tag,  only: [:show, :edit, :update, :destroy]

  def index
    @order = scrub_order(Tag, params[:order], "tags.name")
    @tags = Tag.current.search(params[:search]).order(@order).page(params[:page]).per( 40 )
    respond_with(@tags)
  end

  def show
    respond_with(@tag)
  end

  def new
    @tag = Tag.new
    respond_with(@tag)
  end

  def edit
  end

  def create
    @tag = current_user.tags.new(tag_params)
    @tag.save
    respond_with(@tag)
  end

  def update
    @tag.update(tag_params)
    respond_with(@tag)
  end

  def destroy
    @tag.destroy

    respond_to do |format|
      format.html { redirect_to tags_path }
      format.json { head :no_content }
    end
  end

  private
    def set_tag
      @tag = Tag.current.find_by_id(params[:id])
    end

    def redirect_without_tag
      empty_response_or_root_path( tags_path ) unless @tag
    end


    def tag_params
      params.require(:tag).permit(:name, :color)
    end
end

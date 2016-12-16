# frozen_string_literal: true

# Allows admins to create and modify broadcast categories.
class CategoriesController < ApplicationController
  before_action :authenticate_user!
  before_action :check_system_admin
  before_action :find_category_or_redirect, only: [:show, :edit, :update, :destroy]

  # GET /categories
  def index
    @categories = Category.current.order(:name).page(params[:page]).per(40)
  end

  # GET /categories/1
  def show
  end

  # GET /categories/new
  def new
    @category = Category.new
  end

  # GET /categories/1/edit
  def edit
  end

  # POST /categories
  def create
    @category = Category.new(category_params)

    if @category.save
      redirect_to @category, notice: 'Category was successfully created.'
    else
      render :new
    end
  end

  # PATCH /categories/1
  def update
    if @category.update(category_params)
      redirect_to @category, notice: 'Category was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /categories/1
  def destroy
    @category.destroy
    redirect_to categories_path, notice: 'Category was successfully deleted.'
  end

  private

  def find_category_or_redirect
    @category = Category.current.find_by_param(params[:id])
    redirect_without_category
  end

  def redirect_without_category
    empty_response_or_root_path(categories_path) unless @category
  end

  def category_params
    params.require(:category).permit(:name, :slug)
  end
end

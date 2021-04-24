# frozen_string_literal: true

# Allows admins to create and edit about page FAQs.
class Admin::FaqsController < ApplicationController
  before_action :authenticate_user!
  before_action :check_admin
  before_action :find_faq_or_redirect, only: [:show, :edit, :update, :destroy]

  layout "layouts/full_page_sidebar"

  # GET /faqs
  def index
    scope = Faq.current.search(params[:search], match_start: false)
    @faqs = scope_order(scope).page(params[:page]).per(40)
  end

  # # GET /faqs/1
  # def show
  # end

  # GET /faqs/new
  def new
    @faq = Faq.new
  end

  # # GET /faqs/1/edit
  # def edit
  # end

  # POST /faqs
  def create
    @faq = Faq.new(faq_params)

    if @faq.save
      redirect_to admin_faq_path(@faq), notice: "FAQ was successfully created."
    else
      render :new
    end
  end

  # PATCH /faqs/1
  def update
    if @faq.update(faq_params)
      redirect_to admin_faq_path(@faq), notice: "FAQ was successfully updated."
    else
      render :edit
    end
  end

  # DELETE /faqs/1
  def destroy
    @faq.destroy
    redirect_to admin_faqs_path, notice: "FAQ was successfully deleted."
  end

  private

  def find_faq_or_redirect
    @faq = Faq.current.find_by(id: params[:id])
    redirect_without_faq
  end

  def redirect_without_faq
    empty_response_or_root_path(admin_faqs_path) unless @faq
  end

  # Only allow a list of trusted parameters through.
  def faq_params
    params.require(:faq).permit(:question, :answer, :position, :displayed)
  end

  def scope_order(scope)
    @order = params[:order]
    scope.order(Arel.sql(Faq::ORDERS[params[:order]] || Faq::DEFAULT_ORDER))
  end
end

# frozen_string_literal: true

# Allows admins to view all forum topic and blog post replies in one location.
class Admin::RepliesController < ApplicationController
  before_action :authenticate_user!
  before_action :check_admin

  layout "layouts/full_page_sidebar"

  # GET /admin/replies
  def index
    scope = Reply.current.points
    @replies = scope_order(scope).page(params[:page]).per(40)
  end

  private

  def scope_order(scope)
    @order = params[:order]
    scope.order(Arel.sql(Reply::ORDERS[params[:order]] || Reply::DEFAULT_ORDER))
  end
end

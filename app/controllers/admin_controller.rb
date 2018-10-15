# frozen_string_literal: true

# Dedicated to admin-only tasks of the site
class AdminController < ApplicationController
  before_action :authenticate_user!
  before_action :check_admin

  layout "layouts/full_page_sidebar"

  # # GET /admin
  # def dashboard
  # end

  # GET /admin/agreement-reports
  def agreement_reports
    @agreements = Agreement.current.regular_members
  end

  # # GET /admin/roles
  # def roles
  # end

  # # GET /admin/stats
  # def stats
  # end

  # # GET /admin/sync
  # def sync
  # end

  # # GET /admin/downloads-by-month
  # def downloads_by_month
  # end

  # GET /admin/downloads-by-quarter
  def downloads_by_quarter
    @year = params[:year].to_i.positive? ? params[:year].to_i : Time.zone.today.year
  end

  # GET /admin/searches
  def searches
    @searches = scope_order(Search).page(params[:page]).per(40)
  end

  # GET /admin/spam-report
  def spam_report
    @year = params[:year]
    @spammers = User.where(spammer: true)
    # @shadow_banned = User.where(shadow_banned: true)
    if @year
      @spammers = @spammers.where("EXTRACT(YEAR FROM created_at)::int = ?", @year)
      # @shadow_banned = @shadow_banned.where("EXTRACT(YEAR FROM created_at)::int = ?", @year)
    end
  end

  # GET /admin/spam-inbox
  def spam_inbox
    @spammers = spammers
  end

  # GET /admin/profile-review
  def profile_review
    @users = User.profile_review
  end

  # POST /admin/profile-review
  def submit_profile_review
    user = User.current.find_by(id: params[:user_id])
    if user && params[:approved] == "1"
      user.update(profile_reviewed: true)
      flash[:notice] = "Profile approved."
    elsif user && params[:spammer] == "1"
      user.set_as_spammer_and_destroy!
      flash[:notice] = "Spammer deleted."
    end
    redirect_to admin_profile_review_path
  end

  # POST /admin/unspamban/:id
  def unspamban
    member = spammers.find_by(id: params[:id])
    if member
      member.update(spammer: false)
      flash[:notice] = "Member marked as not a spammer. You may still need to unshadow ban them."
    end
    redirect_to admin_spam_inbox_path
  end

  # POST /admin/empty-spam/:id
  def destroy_spammer
    @spammer = spammers.find_by(id: params[:id])
    return unless @spammer
    @spammer.set_as_spammer_and_destroy!
    @spammers = spammers
  end

  # POST /admin/empty-spam
  def empty_spam
    Topic.current.where(user: spammers).destroy_all
    Notification.where(reply: Reply.where(user: spammers)).destroy_all
    spammers.update_all(spammer: true)
    spammers.destroy_all
    redirect_to admin_spam_inbox_path, notice: "All spammers have been deleted."
  end

  private

  def spammers
    User.spam_review
  end

  def scope_order(scope)
    @order = params[:order]
    scope.order(Arel.sql(Search::ORDERS[params[:order]] || Search::DEFAULT_ORDER))
  end
end

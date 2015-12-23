# Displays publicly available pages
class ExternalController < ApplicationController
  def about
    @users = User.core_members.order(:last_name, :first_name)
  end

  def contact
  end

  def landing
    @datasets = Dataset.release_scheduled
    @variables = Variable.where(dataset_id: Dataset.current.where(public: true).select(:id), commonly_used: true).order('RANDOM()').limit(10)
    @tools = Tool.current.where(slug: ['physiomimi', 'edf-viewer', 'block-edf-loader']).order(:name)
  end

  def sitemap
  end

  def preview
  end
end

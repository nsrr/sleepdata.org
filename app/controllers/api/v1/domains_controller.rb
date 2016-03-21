# frozen_string_literal: true

class Api::V1::DomainsController < Api::V1::BaseController
  before_action :set_domain, only: [:show, :edit, :update, :destroy]

  # # GET /api/v1/domains.json
  # def index
  #   @domains = Domain.order(id: :desc).limit(5)
  # end

  # # GET /api/v1/domains/1.json
  # def show
  # end

  # # POST /api/v1/domains.json
  # def create
  #   @domain = Api::V1::Domain.new(domain_params)

  #   respond_to do |format|
  #     if @domain.save
  #       format.json { render :show, status: :created, location: @domain }
  #     else
  #       format.json { render json: @domain.errors, status: :unprocessable_entity }
  #     end
  #   end
  # end

  # # PATCH/PUT /api/v1/domains/1.json
  # def update
  #   respond_to do |format|
  #     if @domain.update(domain_params)
  #       format.json { render :show, status: :ok, location: @domain }
  #     else
  #       format.json { render json: @domain.errors, status: :unprocessable_entity }
  #     end
  #   end
  # end

  # # DELETE /api/v1/domains/1.json
  # def destroy
  #   @domain.destroy
  #   respond_to do |format|
  #     format.json { head :no_content }
  #   end
  # end

  # private

  # def set_domain
  #   @domain = Api::V1::Domain.find_by_id(params[:id])
  # end

  # def domain_params
  #   params.require(:domain).permit(:name)
  # end
end

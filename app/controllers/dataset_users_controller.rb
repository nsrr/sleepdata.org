# frozen_string_literal: true

class DatasetUsersController < ApplicationController
  # before_action :set_dataset_user, only: [:show, :edit, :update, :destroy]

  # # GET /dataset_users
  # # GET /dataset_users.json
  # def index
  #   @dataset_users = DatasetUser.all
  # end

  # # GET /dataset_users/1
  # # GET /dataset_users/1.json
  # def show
  # end

  # # GET /dataset_users/new
  # def new
  #   @dataset_user = DatasetUser.new
  # end

  # # GET /dataset_users/1/edit
  # def edit
  # end

  # # POST /dataset_users
  # # POST /dataset_users.json
  # def create
  #   @dataset_user = DatasetUser.new(dataset_user_params)

  #   respond_to do |format|
  #     if @dataset_user.save
  #       format.html { redirect_to @dataset_user, notice: 'Dataset user was successfully created.' }
  #       format.json { render action: 'show', status: :created, location: @dataset_user }
  #     else
  #       format.html { render action: 'new' }
  #       format.json { render json: @dataset_user.errors, status: :unprocessable_entity }
  #     end
  #   end
  # end

  # # PATCH/PUT /dataset_users/1
  # # PATCH/PUT /dataset_users/1.json
  # def update
  #   respond_to do |format|
  #     if @dataset_user.update(dataset_user_params)
  #       format.html { redirect_to @dataset_user, notice: 'Dataset user was successfully updated.' }
  #       format.json { head :no_content }
  #     else
  #       format.html { render action: 'edit' }
  #       format.json { render json: @dataset_user.errors, status: :unprocessable_entity }
  #     end
  #   end
  # end

  # # DELETE /dataset_users/1
  # # DELETE /dataset_users/1.json
  # def destroy
  #   @dataset_user.destroy
  #   respond_to do |format|
  #     format.html { redirect_to dataset_users_url }
  #     format.json { head :no_content }
  #   end
  # end

  # private
  #   # Use callbacks to share common setup or constraints between actions.
  #   def set_dataset_user
  #     @dataset_user = DatasetUser.find(params[:id])
  #   end

  #   # Never trust parameters from the scary internet, only allow the white list through.
  #   def dataset_user_params
  #     params.require(:dataset_user).permit(:dataset_id, :user_id, :editor, :approved)
  #   end
end

# frozen_string_literal: true

class ChallengesController < ApplicationController
  before_action :authenticate_user!,          except: [:index, :show, :images]
  before_action :check_system_admin,          only: [:new, :create, :edit, :update, :destroy]

  before_action :set_viewable_challenge,      only: [:show, :images, :signal, :update_signal, :review, :submitted]
  before_action :set_editable_challenge,      only: [:edit, :update, :destroy]
  before_action :redirect_without_challenge,  only: [:show, :images, :signal, :update_signal, :review, :submitted, :edit, :update, :destroy]

  before_action :set_signal_map,              only: [:signal, :update_signal, :review, :submitted]

  # GET /challenges
  def index
    @challenges = Challenge.all
  end

  # GET /challenges/1
  def show
  end

  def signal
  end

  def update_signal
    range = @signal_map[@signal - 1]
    number = format('%02d', @signal)
    blank_found = false

    range.each do |letter|
      question_name = "signal#{number}#{letter.downcase}"
      question = @challenge.questions.find_by_name(question_name)
      answer = @challenge.answers.where(question_id: question.id, user_id: current_user.id).first_or_create
      if %w(yes no intermediate unscorable).include?(params[question_name])
        answer.update response: params[question_name]
      else
        blank_found = true
      end
    end

    if blank_found
      flash[:alert] = 'Please answer every question.'
      redirect_to signal_challenge_path(@challenge, signal: @signal)
    else
      if @signal == @challenge.signal_count
        redirect_to review_challenge_path(@challenge)
      else
        redirect_to signal_challenge_path(@challenge, signal: @signal + 1)
      end
    end
  end

  # GET /challenges/new
  def new
    @challenge = Challenge.new
  end

  # GET /challenges/1/edit
  def edit
  end

  # POST /challenges
  def create
    @challenge = current_user.challenges.new(challenge_params)

    if @challenge.save
      redirect_to @challenge, notice: 'Challenge was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /challenges/1
  def update
    if @challenge.update(challenge_params)
      redirect_to @challenge, notice: 'Challenge was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /challenges/1
  def destroy
    @challenge.destroy
    redirect_to challenges_path, notice: 'Challenge was successfully destroyed.'
  end

  def images
    valid_files = Dir.glob(File.join(@challenge.images_folder, '**', '*.{jpg,png}')).collect{|i| i.gsub(File.join(@challenge.images_folder) + '/', '')}

    @image_file = valid_files.find { |i| i == params[:path] }
    if @image_file && params[:inline] != '1'
      send_file File.join(@challenge.images_folder, @image_file)
    elsif @image_file
      render 'documentation/images'
    else
      head :ok
    end
  end

  private

  def set_viewable_challenge
    viewable_challenges = if current_user
                            current_user.all_viewable_challenges
                          else
                            Challenge.current.where(public: true)
                          end
    @challenge = viewable_challenges.find_by_slug(params[:id])
  end

  def set_editable_challenge
    @challenge = current_user.all_challenges.find_by_slug params[:id]
  end

  def redirect_without_challenge
    empty_response_or_root_path(challenges_path) unless @challenge
  end

  def challenge_params
    params.require(:challenge).permit(:name, :slug, :description, :public)
  end

  def set_signal_map
    @signal = [params[:signal].to_i, 1].max

    @signal_map = @challenge.signal_map
  end
end

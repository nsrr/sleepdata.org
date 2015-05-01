class ChallengesController < ApplicationController
  before_action :authenticate_user!,          except: [ :index, :show, :images ]
  before_action :check_system_admin,          only: [ :new, :create, :edit, :update, :destroy ]

  before_action :set_viewable_challenge,      only: [ :show, :images, :signal, :update_signal, :review ]
  before_action :set_editable_challenge,      only: [ :edit, :update, :destroy ]
  before_action :redirect_without_challenge,  only: [ :show, :images, :signal, :update_signal, :review, :edit, :update, :destroy ]

  before_action :set_signal_map,              only: [ :signal, :update_signal, :review ]

  layout 'application-full'

  # GET /challenges
  # GET /challenges.json
  def index
    @challenges = Challenge.all
  end

  # GET /challenges/1
  # GET /challenges/1.json
  def show
  end

  def signal
  end

  def update_signal
    range = @signal_map[@signal - 1]
    number = "%02d" % @signal
    blank_found = false

    range.each do |letter|
      question_name = "signal#{number}#{letter.downcase}"
      question = @challenge.questions.find_by_name(question_name)
      answer = @challenge.answers.where(question_id: question.id, user_id: current_user.id).first_or_create
      if ['yes', 'no', 'intermediate', 'unscorable'].include?(params[question_name])
        answer.update response: params[question_name]
      else
        blank_found = true
      end
    end

    if blank_found
      flash[:alert] = "Please answer every question."
      redirect_to signal_challenge_path(@challenge, signal: @signal)
    else
      if @signal == 30
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
  # POST /challenges.json
  def create
    @challenge = current_user.challenges.new(challenge_params)

    respond_to do |format|
      if @challenge.save
        format.html { redirect_to @challenge, notice: 'Challenge was successfully created.' }
        format.json { render :show, status: :created, location: @challenge }
      else
        format.html { render :new }
        format.json { render json: @challenge.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /challenges/1
  # PATCH/PUT /challenges/1.json
  def update
    respond_to do |format|
      if @challenge.update(challenge_params)
        format.html { redirect_to @challenge, notice: 'Challenge was successfully updated.' }
        format.json { render :show, status: :ok, location: @challenge }
      else
        format.html { render :edit }
        format.json { render json: @challenge.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /challenges/1
  # DELETE /challenges/1.json
  def destroy
    @challenge.destroy
    respond_to do |format|
      format.html { redirect_to challenges_url, notice: 'Challenge was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def images
    valid_files = Dir.glob(File.join(@challenge.images_folder, '**', '*.{jpg,png}')).collect{|i| i.gsub(File.join(@challenge.images_folder) + '/', '')}

    @image_file = valid_files.select{|i| i == params[:path] }.first
    if @image_file and params[:inline] != '1'
      send_file File.join( @challenge.images_folder, @image_file )
    elsif @image_file
      render 'documentation/images'
    else
      render nothing: true
    end
  end

  private
    def set_viewable_challenge
      viewable_challenges = if current_user
        current_user.all_viewable_challenges
      else
        Challenge.current.where( public: true )
      end
      @challenge = viewable_challenges.find_by_slug(params[:id])
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_editable_challenge
      @challenge = current_user.all_challenges.find_by_slug(params[:id])
    end

    def redirect_without_challenge
      empty_response_or_root_path(challenges_path) unless @challenge
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def challenge_params
      params.require(:challenge).permit(:name, :slug, :description, :public)
    end

    def set_signal_map
      @signal = [params[:signal].to_i, 1].max

      @signal_map = Challenge::SIGNAL_MAP
    end
end

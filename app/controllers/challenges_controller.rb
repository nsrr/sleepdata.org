class ChallengesController < ApplicationController
  before_action :authenticate_user!,          except: [ :index, :show, :images ]
  before_action :check_system_admin,          only: [ :new, :create, :edit, :update, :destroy ]

  before_action :set_viewable_challenge,      only: [ :show, :images, :signal ]
  before_action :set_editable_challenge,      only: [ :edit, :update, :destroy ]
  before_action :redirect_without_challenge,  only: [ :show, :images, :signal, :edit, :update, :destroy ]

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
    @signal = [params[:signal].to_i, 1].max

    @signal_map = [('A'..'R'), ('A'..'V'), ('A'..'P'), ('A'..'N'), ('A'..'P'),
                   ('A'..'S'), ('A'..'M'), ('A'..'M'), ('A'..'P'), ('A'..'M'),
                   ('A'..'O'), ('A'..'S'), ('A'..'R'), ('A'..'P'), ('A'..'M'),
                   ('A'..'R'), ('A'..'P'), ('A'..'J'), ('A'..'S'), ('A'..'L'),
                   ('A'..'M'), ('A'..'P'), ('A'..'M'), ('A'..'K'), ('A'..'M'),
                   ('A'..'U'), ('A'..'O'), ('A'..'O'), ('A'..'L'), ('A'..'N')]
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
end

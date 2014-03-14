class AgreementsController < ApplicationController
  before_action :authenticate_user!,          except: [ :dua ]
  before_action :check_system_admin,          except: [ :dua, :submit, :resubmit ]
  before_action :set_agreement,               only: [ :show, :destroy, :download, :review, :update ]
  before_action :redirect_without_agreement,  only: [ :show, :destroy, :download, :review, :update ]

  # GET /dua
  def dua
    if current_user
      @agreement = Agreement.current.where( user_id: current_user.id ).first
      if @agreement and @agreement.approved?
        render 'dua_approved'
      elsif @agreement
        render 'dua_submitted'
      else
        render 'dua'
      end
    else
      render 'dua_sign_in'
    end
  end

  # POST /dua
  # POST /dua.json
  def submit
    @agreement = current_user.agreements.new(dua_submission_params)

    if current_user.agreements.count > 0
      redirect_to dua_path
      return
    end

    respond_to do |format|
      if @agreement.save
        @agreement.add_event!('Data Access and Use Agreement submitted.', current_user, 'submitted')
        @agreement.dua_submitted
        format.html { redirect_to dua_path, notice: 'Agreement was successfully created.' }
        format.json { render action: 'show', status: :created, location: @agreement }
      else
        format.html { render action: 'dua' }
        format.json { render json: @agreement.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH /dua
  # PATCH /dua.json
  def resubmit
    @agreement = Agreement.current.where( user_id: current_user.id ).first

    respond_to do |format|
      if @agreement.update(dua_submission_params)
        @agreement.add_event!('Data Access and Use Agreement resubmitted.', current_user, 'submitted')
        @agreement.dua_submitted
        format.html { redirect_to dua_path, notice: 'Agreement was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'dua_submitted' }
        format.json { render json: @agreement.errors, status: :unprocessable_entity }
      end
    end
  end

  # GET /agreements
  # GET /agreements.json
  def index
    @agreements = Agreement.current.search(params[:search]).order(expiration_date: :desc).page(params[:page]).per( 40 )
  end

  # GET /agreements/1
  # GET /agreements/1.json
  def show
  end

  # # GET /agreements/new
  # def new
  #   @agreement = Agreement.new
  # end

  # # GET /agreements/1/edit
  # def edit
  # end

  # This is the "edit action"
  # GET /agreements/1/review
  def review
  end

  # PATCH /agreements/1
  # PATCH /agreements/1.json
  def update
    original_status = @agreement.status
    respond_to do |format|
      if @agreement.update(agreement_review_params)
        if original_status != 'approved' and @agreement.status == 'approved'
          @agreement.update( approval_date: Date.today, expiration_date: Date.today + 3.years )
          @agreement.dua_approved_email(current_user)
        elsif original_status != 'resubmit' and @agreement.status == 'resubmit'
          @agreement.sent_back_for_resubmission_email(current_user)
        end
        format.html { redirect_to @agreement, notice: 'Agreement was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'review' }
        format.json { render json: @agreement.errors, status: :unprocessable_entity }
      end
    end
  end

  def download
    send_file File.join( CarrierWave::Uploader::Base.root, (params[:executed] == '1' ? @agreement.executed_dua.url : @agreement.dua.url) ), disposition: 'inline'
  end

  # DELETE /agreements/1
  # DELETE /agreements/1.json
  def destroy
    @agreement.destroy

    respond_to do |format|
      format.html { redirect_to agreements_path }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_agreement
      @agreement = Agreement.current.find_by_id(params[:id])
    end

    def redirect_without_agreement
      empty_response_or_root_path( current_user && current_user.system_admin? ? agreements_path : dua_path ) unless @agreement
    end

    def agreement_review_params
      params.require(:agreement).permit(:executed_dua, :executed_dua_cache, :evidence_of_irb_review, :status, :comments)
    end

    def dua_submission_params
      params[:agreement] ||= { dua: '', remove_dua: '1' }
      params.require(:agreement).permit(:dua, :remove_dua)
    end

end

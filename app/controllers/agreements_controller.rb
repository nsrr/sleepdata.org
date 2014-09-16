class AgreementsController < ApplicationController
  before_action :authenticate_user!,          except: [ :daua, :dua ]
  before_action :check_system_admin,          except: [ :daua, :dua, :submit, :resubmit, :step, :update_step ]
  before_action :set_step,                    only: [ :new_step, :create_step, :step, :update_step ]
  before_action :set_agreement,               only: [ :show, :destroy, :download, :review, :step, :update, :update_step ]
  before_action :redirect_without_agreement,  only: [ :show, :destroy, :download, :review, :step, :update, :update_step ]

  def step
    if params[:step].to_i > 0 and params[:step].to_i < 10
      @step = params[:step].to_i
      render "agreements/wizard/step#{@step}"
    else
      redirect_to daua_step_path(step: 1)
    end
  end

  def new_step
    @agreement = current_user.agreements.new
    render "agreements/wizard/step#{@step}"
  end

  # POST /agreements
  def create_step
    @agreement = current_user.agreements.new(step_params)

    if @agreement.save
      # @agreement.add_event!('Data Access and Use Agreement submitted.', current_user, 'submitted')
      # @agreement.daua_submitted
      # redirect_to daua_path, notice: 'Agreement was successfully created.'
      redirect_to step_agreement_path(@agreement, step: 2)
    else
      render "agreements/wizard/step#{@step}"
    end

  end


  def update_step
    if @agreement.update(step_params)
      redirect_to step_agreement_path(@agreement, step: @agreement.current_step+1)
    else
      render "agreements/wizard/step#{@step}"
    end
  end

  def dua
    redirect_to daua_path
  end

  # GET /daua
  def daua
    if current_user
      @agreement = Agreement.current.where( user_id: current_user.id ).first
      if @agreement and @agreement.approved?
        @datasets = Dataset.release_scheduled
        render 'daua_approved'
      elsif @agreement
        render 'daua_submitted'
      else
        render 'daua'
      end
    else
      render 'daua_sign_in'
    end
  end

  # POST /daua
  # POST /daua.json
  def submit
    @agreement = current_user.agreements.new(daua_submission_params)

    if current_user.agreements.count > 0
      redirect_to daua_path
      return
    end

    respond_to do |format|
      if @agreement.save
        @agreement.add_event!('Data Access and Use Agreement submitted.', current_user, 'submitted')
        @agreement.daua_submitted
        format.html { redirect_to daua_path, notice: 'Agreement was successfully created.' }
        format.json { render action: 'show', status: :created, location: @agreement }
      else
        format.html { render action: 'daua' }
        format.json { render json: @agreement.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH /daua
  # PATCH /daua.json
  def resubmit
    @agreement = Agreement.current.where( user_id: current_user.id ).first

    respond_to do |format|
      if @agreement.update(daua_submission_params)
        @agreement.add_event!('Data Access and Use Agreement resubmitted.', current_user, 'submitted')
        @agreement.daua_submitted
        format.html { redirect_to daua_path, notice: 'Agreement was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'daua_submitted' }
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
          @agreement.daua_approved_email(current_user)
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
      empty_response_or_root_path( current_user && current_user.system_admin? ? agreements_path : daua_path ) unless @agreement
    end

    def agreement_review_params
      params.require(:agreement).permit(:executed_dua, :executed_dua_cache, :evidence_of_irb_review, :status, :comments)
    end

    def daua_submission_params
      params[:agreement] ||= { dua: '', remove_dua: '1' }
      params.require(:agreement).permit(:dua, :remove_dua)
    end

    def set_step
      if params[:step].to_i > 0 and params[:step].to_i < 10
        @step = params[:step].to_i
      else
        @step = 1
      end
    end

    def step_params
      params[:agreement] ||= {}
      params[:agreement][:signature_date] = parse_date(params[:agreement][:signature_date]) if params[:agreement].key?(:signature_date)

      params.require(:agreement).permit(
        :current_step,
        # Step One
          :data_user, :data_user_type,
        #   Individual
          :individual_institution_name, :individual_title, :individual_telephone, :individual_fax, :individual_address,
        #   Organization
          :organization_business_name, :organization_contact_name, :organization_contact_title, :organization_contact_telephone, :organization_contact_fax, :organization_contact_email, :organization_address,
        # Step Two
          :specific_purpose,
        # Step Three
          :has_read_step3,
        # Step Four
          :posting_permission,
        # Step Five
          :has_read_step5,
        # Step Six
          :signature, :signature_print, :signature_date,
        # Step Seven
          :irb_evidence_type, :irb
      )
    end

end

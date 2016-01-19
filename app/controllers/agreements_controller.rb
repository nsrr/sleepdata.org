class AgreementsController < ApplicationController
  prepend_before_filter only: [:signature_requested, :duly_authorized_representative_submit_signature, :signature_submitted] { request.env['devise.skip_timeout'] = true }
  skip_before_action :verify_authenticity_token, only: [:signature_requested, :duly_authorized_representative_submit_signature, :signature_submitted]

  before_action :authenticate_user!,             except: [:signature_requested, :duly_authorized_representative_submit_signature, :signature_submitted]
  before_action :check_system_admin,             except: [:signature_requested, :duly_authorized_representative_submit_signature, :signature_submitted, :renew, :daua, :dua, :create_step, :step, :update_step, :proof, :final_submission, :destroy_submission, :download_irb, :print, :complete, :new_step, :irb_assistance]

  before_action :set_viewable_submission,        only: [:renew, :complete]
  before_action :set_editable_submission,        only: [:step, :update_step, :proof, :final_submission, :destroy_submission]
  before_action :redirect_without_submission,    only: [:step, :update_step, :proof, :final_submission, :destroy_submission, :renew, :complete]
  before_action :set_step,                       only: [:create_step, :step, :update_step]

  before_action :set_downloadable_irb_agreement, only: [:download_irb, :print]
  before_action :set_agreement,                  only: [:destroy, :download, :update]
  before_action :redirect_without_agreement,     only: [:destroy, :download, :update, :download_irb, :print]

  def signature_requested
    @agreement = Agreement.current.where(id: params[:id], status: [nil, '', 'started', 'resubmit']).find_by_duly_authorized_representative_token(params[:duly_authorized_representative_token]) unless params[:duly_authorized_representative_token].blank?
    @step = 4
    unless @agreement
      redirect_to root_path, alert: 'Agreement has been locked.'
    end
  end

  def duly_authorized_representative_submit_signature
    @agreement = Agreement.current.where(id: params[:id], status: [nil, '', 'started', 'resubmit']).find_by_duly_authorized_representative_token(params[:duly_authorized_representative_token]) unless params[:duly_authorized_representative_token].blank?
    @step = 4
    if @agreement
      if AgreementTransaction.save_agreement!(@agreement, duly_authorized_params, current_user, request.remote_ip, 'public_agreement_update')
        @agreement.update_column :current_step, 4
        @agreement.send_daua_signed_email_in_background
        redirect_to signature_submitted_agreements_path
      else
        render 'signature_requested'
      end
    else
      redirect_to root_path, alert: 'Agreement has been locked.'
    end
  end

  def signature_submitted

  end

  def step
    if @step and @step > 0 and @step < 6
      render "agreements/wizard/step#{@step}"
    elsif @step == 6
      render "agreements/proof"
    else
      redirect_to step_agreement_path(@agreement, step: 1)
    end
  end

  def new_step
    @step = 1
    @agreement = current_user.agreements.new( data_user: current_user.name )
    render "agreements/wizard/step#{@step}"
  end

  def renew
    @step = 1
    @agreement = current_user.agreements.create( @agreement.copyable_attributes )
    render "agreements/wizard/step#{@step}"
  end

  # POST /agreements
  def create_step
    @agreement = current_user.agreements.new(step_params)

    if AgreementTransaction.save_agreement!(@agreement, step_params, current_user, request.remote_ip, 'agreement_create')
      if @agreement.draft_mode?
        redirect_to submissions_path
      else
        redirect_to step_agreement_path(@agreement, step: 2)
      end
    else
      render "agreements/wizard/step#{@step}"
    end

  end

  def update_step
    if AgreementTransaction.save_agreement!(@agreement, step_params, current_user, request.remote_ip, 'agreement_update')
      if @agreement.draft_mode?
        redirect_to submissions_path
      elsif @agreement.fully_filled_out? or @agreement.current_step == 5
        redirect_to proof_agreement_path(@agreement)
      else
        redirect_to step_agreement_path(@agreement, step: @agreement.current_step + 1)
      end
    elsif @step
      render "agreements/wizard/step#{@step}"
    else
      redirect_to submissions_path
    end
  end

  def proof
    @step = 6
  end

  def final_submission
    current_time = Time.zone.now
    if @agreement.status == 'resubmit'
      hash = { status: 'submitted', resubmitted_at: current_time, last_submitted_at: current_time }
      msg = "Data Access and Use Agreement resubmitted."
      event_type = 'user_resubmitted'
    else
      hash = { status: 'submitted', submitted_at: current_time, last_submitted_at: current_time }
      msg = "Data Access and Use Agreement submitted."
      event_type = 'user_submitted'
    end

    if not @agreement.fully_filled_out?
      render 'proof'
    elsif AgreementTransaction.save_agreement!(@agreement, hash, current_user, request.remote_ip, 'agreement_update')
      @agreement.add_event!(msg, current_user, 'submitted')
      @agreement.agreement_events.create event_type: event_type, user_id: current_user.id, event_at: current_time
      @agreement.daua_submitted
      redirect_to complete_agreement_path(@agreement)
    else
      redirect_to submissions_path
    end
  end

  # GET /agreements
  # GET /agreements.json
  def index
    redirect_to reviews_path
  end

  def export
    @csv_string = CSV.generate do |csv|
      csv << [
        'Status',
        'Last Submitted Date',
        'Approval Date',
        'Expiration Date',
        'Approved By',
        'Rejected By',
        'Agreement',
        'Data User',
        'Data User Type',
        'Individual Institution Name',
        'Individual Name',
        'Individual Title',
        'Individual Telephone',
        'Individual Fax',
        'Individual Email',
        'Individual Address',
        'Organization Business Name',
        'Organization Contact Name',
        'Organization Contact Title',
        'Organization Contact Telephone',
        'Organization Contact Fax',
        'Organization Contact Email',
        'Organization Address',
        'Title of Project',
        'Specific Purpose',
        'Datasets',
        'Posting Permission',
        'Unauthorized to Sign',
        'Signature Print',
        'Signature Date',
        'Duly Authorized Representative Signature Print',
        'Duly Authorized Representative Signature Date',
        'IRB Evidence Type',
        'Intended Use of Data',
        'Data Secured Location',
        'Secured Device',
        'Human Subjects Protections Trained'
      ] + Tag.review_tags.order(:name).pluck(:name)

      Agreement.current.includes(agreement_tags: :tag).each do |a|
        row = [
          a.status,
          a.last_submitted_at,
          a.approval_date,
          a.expiration_date,
          a.reviews.where(approved: true).collect{|r| r.user.initials}.join(','),
          a.reviews.where(approved: false).collect{|r| r.user.initials}.join(','),
          a.name,
          a.data_user,
          a.data_user_type,
          a.individual_institution_name,
          a.user.name,
          a.individual_title,
          a.individual_telephone,
          a.individual_fax,
          a.user.email,
          a.individual_address,
          a.organization_business_name,
          a.organization_contact_name,
          a.organization_contact_title,
          a.organization_contact_telephone,
          a.organization_contact_fax,
          a.organization_contact_email,
          a.organization_address,
          a.title_of_project,
          a.specific_purpose,
          a.datasets.pluck(:name).sort.join(', '),
          a.posting_permission,
          a.unauthorized_to_sign,
          a.signature_print,
          a.signature_date,
          a.duly_authorized_representative_signature_print,
          a.duly_authorized_representative_signature_date,
          a.irb_evidence_type,
          a.intended_use_of_data,
          a.data_secured_location,
          a.secured_device,
          a.human_subjects_protections_trained
        ]
        Tag.review_tags.order(:name).each do |tag|
          row << a.tags.collect(&:id).include?(tag.id)
        end
        csv << row
      end
    end

    send_data @csv_string, type: 'text/csv; charset=iso-8859-1; header=present',
                           disposition: "attachment; filename=\"Agreements List - #{Time.zone.now.strftime("%Y.%m.%d %Ih%M %p")}.csv\""
  end

  # GET /agreements/1
  # GET /agreements/1.json
  def show
    redirect_to reviews_path
  end

  # # GET /agreements/new
  # def new
  #   @agreement = Agreement.new
  # end

  # # GET /agreements/1/edit
  # def edit
  # end

  # PATCH /agreements/1
  def update
    original_status = @agreement.status
    if AgreementTransaction.save_agreement!(@agreement, agreement_review_params, current_user, request.remote_ip, 'agreement_update')
      if original_status != 'approved' and @agreement.status == 'approved'
        @agreement.daua_approved_email(current_user)
      elsif original_status != 'resubmit' and @agreement.status == 'resubmit'
        @agreement.sent_back_for_resubmission_email(current_user)
      end
      redirect_to review_path(@agreement) + "#c#{@agreement.agreement_events.last.number}", notice: 'Agreement was successfully updated.'
    else
      render 'reviews/show'
    end
  end

  def download_irb
    send_file File.join(CarrierWave::Uploader::Base.root, @agreement.irb.url), disposition: 'inline'
  end

  def print
    @agreement.generate_printed_pdf!
    if @agreement.printed_file.size > 0
      send_file File.join( CarrierWave::Uploader::Base.root, @agreement.printed_file.url ), filename: "#{@agreement.user.last_name.gsub(/[^a-zA-Z\p{L}]/, '')}-#{@agreement.user.first_name.gsub(/[^a-zA-Z\p{L}]/, '')}-#{@agreement.agreement_number}-DAUA-#{(@agreement.submitted_at || @agreement.created_at).strftime("%Y-%m-%d")}.pdf", type: "application/pdf", disposition: "inline"
    else
      render layout: false
    end
  end

  def download
    send_file File.join( CarrierWave::Uploader::Base.root, (params[:executed] == '1' ? @agreement.executed_dua.url : @agreement.dua.url) ), disposition: 'inline'
  end

  def destroy_submission
    @agreement.destroy
    redirect_to submissions_path
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

    def set_downloadable_irb_agreement
      @agreement = current_user.all_agreements.find_by_id(params[:id])
    end

    def set_viewable_submission
      @agreement = current_user.agreements.find_by_id(params[:id])
    end

    def set_editable_submission
      @agreement = current_user.agreements.where( status: [nil, '', 'started', 'resubmit'] ).find_by_id(params[:id])
    end

    def redirect_without_submission
      empty_response_or_root_path( submissions_path ) unless @agreement
    end

    def redirect_without_agreement
      empty_response_or_root_path( current_user && current_user.system_admin? ? agreements_path : submissions_path ) unless @agreement
    end

    def agreement_review_params
      params[:agreement] ||= {}
      [:approval_date, :expiration_date].each do |date|
        params[:agreement][date] = parse_date(params[:agreement][date]) if params[:agreement].key?(date)
      end

      params.require(:agreement).permit(:current_step, :status, :comments, :approval_date, :expiration_date, :reviewer_signature, { dataset_ids: [] })
    end

    def daua_submission_params
      params[:agreement] ||= { dua: '', remove_dua: '1' }
      params.require(:agreement).permit(:dua, :remove_dua)
    end

    def set_step
      @step = params[:step].to_i if params[:step].to_i > 0 and params[:step].to_i < 9
    end

    def step_params
      params[:agreement] ||= {}
      params[:agreement][:signature_date] = parse_date(params[:agreement][:signature_date]) if params[:agreement].key?(:signature_date)

      if params[:agreement].key?(:dataset_ids)
        params[:agreement][:dataset_ids] = Dataset.release_scheduled.where( id: params[:agreement][:dataset_ids] ).pluck(:id)
      end

      params.require(:agreement).permit(
        :current_step, :draft_mode,
        # Step One
          :data_user, :data_user_type,
        #   Individual
          :individual_institution_name, :individual_title, :individual_telephone, :individual_address,
        #   Organization
          :organization_business_name, :organization_contact_name, :organization_contact_title, :organization_contact_telephone, :organization_contact_email, :organization_address,
        # Step Two
          :specific_purpose, { dataset_ids: [] },
        # Step Three
          :has_read_step3,
        # Step Four
          :posting_permission,
        # Step Five
          :has_read_step5,
        # Step Six
          :unauthorized_to_sign,
          # Data User Authorized to Sign
          :signature, :signature_print, :signature_date,
          # Duly Authorized Representative to Sign
          :duly_authorized_representative_signature_print,
        # Step Seven
          :irb_evidence_type, :irb,
        # Step Eight
          :title_of_project, :intended_use_of_data, :data_secured_location, :secured_device, :human_subjects_protections_trained
      )
    end

    def duly_authorized_params
      params[:agreement] ||= {}
      params[:agreement][:duly_authorized_representative_signature_date] = parse_date(params[:agreement][:duly_authorized_representative_signature_date]) if params[:agreement].key?(:duly_authorized_representative_signature_date)
      params[:agreement][:unauthorized_to_sign] = true

      params.require(:agreement).permit(
        :current_step,
        # Duly Authorized Representative to Sign
        :duly_authorized_representative_signature_print, :duly_authorized_representative_signature, :duly_authorized_representative_signature_date, :duly_authorized_representative_title,
        # Automatically set
        :unauthorized_to_sign
      )
    end

end

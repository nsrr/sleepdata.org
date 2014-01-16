class AgreementsController < ApplicationController
  before_action :authenticate_user!,          except: [ :dua ]
  before_action :check_system_admin,          except: [ :create, :update, :dua ]
  before_action :set_agreement,               only: [ :show, :destroy, :set_approval, :download ]
  before_action :redirect_without_agreement,  only: [ :show, :destroy, :set_approval, :download ]

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

  # GET /agreements
  # GET /agreements.json
  def index
    @agreements = Agreement.current.order('id').page(params[:page]).per( 20 )
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

  def download
    send_file File.join( CarrierWave::Uploader::Base.root, @agreement.dua.url )
  end

  # POST /agreements
  # POST /agreements.json
  def create
    @agreement = current_user.agreements.new(agreement_params)

    if current_user.agreements.count > 0
      redirect_to dua_path
      return
    end

    respond_to do |format|
      if @agreement.save
        @agreement.add_event!('Data Use Agreement submitted.', current_user, 'submitted')
        format.html { redirect_to dua_path, notice: 'Agreement was successfully created.' }
        format.json { render action: 'show', status: :created, location: @agreement }
      else
        format.html { render action: 'dua' }
        format.json { render json: @agreement.errors, status: :unprocessable_entity }
      end
    end
  end

  def set_approval
    if params[:approved] == '1' and @agreement.status != 'approved'
      @agreement.update( status: 'approved', approval_date: Date.today, expiration_date: Date.today + 3.years )
      @agreement.add_event!('Data Use Agreement approved.', current_user, 'approved')
    elsif params[:approved] == '0' and @agreement.status != 'resubmit'
      @agreement.update( status: 'resubmit' )
      @agreement.add_event!('Data Use Agreement sent back for resubmission.', current_user, 'resubmit')
    end

    redirect_to @agreement
  end

  # PUT /agreements/1
  # PUT /agreements/1.json
  def update
    @agreement = Agreement.current.where( user_id: current_user.id ).first

    respond_to do |format|
      if @agreement.update(agreement_params)
        @agreement.add_event!('Data Use Agreement resubmitted.', current_user, 'submitted')
        format.html { redirect_to dua_path, notice: 'Agreement was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'dua_submitted' }
        format.json { render json: @agreement.errors, status: :unprocessable_entity }
      end
    end
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

    # Never trust parameters from the scary internet, only allow the white list through.
    def agreement_params
      params[:agreement] ||= { dua: '', remove_dua: '1' }
      params.require(:agreement).permit(:dua, :remove_dua)
    end

end

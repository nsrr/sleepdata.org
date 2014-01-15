class AgreementsController < ApplicationController
  before_action :authenticate_user!,          except: [ :create, :dua ]
  before_action :check_system_admin,          except: [ :create, :dua ]
  before_action :set_agreement,               only: [ :show, :edit, :update, :destroy, :set_approval ]
  before_action :redirect_without_agreement,  only: [ :show, :edit, :update, :destroy, :set_approval ]

  def dua
    if current_user and @agreement = Agreement.current.where( user_id: current_user.id ).first
      if @agreement.approved?
        render 'dua_approved'
      else
        render 'dua_submitted'
      end
    else
      render 'dua'
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

  # GET /agreements/new
  def new
    @agreement = Agreement.new
  end

  # GET /agreements/1/edit
  def edit
  end

  # POST /agreements
  # POST /agreements.json
  def create
    @agreement = Agreement.new(agreement_params)

    respond_to do |format|
      if @agreement.save
        @agreement.add_event!('Data Use Agreement submitted.', nil)
        format.html { redirect_to dua_path, notice: 'Agreement was successfully created.' }
        format.json { render action: 'show', status: :created, location: @agreement }
      else
        format.html { render action: 'dua' }
        format.json { render json: @agreement.errors, status: :unprocessable_entity }
      end
    end
  end

  def set_approval
    if params[:approved] == '1'
      @agreement.update( status: 'approved' )
      @agreement.add_event!('Data Use Agreement approved.', current_user)
    elsif params[:approved] == '0'
      @agreement.update( status: 'resubmit' )
      @agreement.add_event!('Data Use Agreement sent back for resubmission.', current_user)
    end

    redirect_to @agreement
  end

  # PUT /agreements/1
  # PUT /agreements/1.json
  def update
    respond_to do |format|
      if @agreement.update(agreement_params)
        format.html { redirect_to @agreement, notice: 'Agreement was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
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
      empty_response_or_root_path( agreements_path ) unless @agreement
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def agreement_params
      params[:agreement] ||= { blank: '1' }

      if current_user and current_user.system_admin?
        params.require(:agreement).permit(:dua, :status, :user_id)
      else
        params[:agreement][:status] == 'submitted'
        params.require(:agreement).permit(:dua, :status)
      end
    end

end

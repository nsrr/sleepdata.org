class Agreement < ActiveRecord::Base

  # STEP 1 Fields:
  #   :data_user
  #   :data_user_type => 'individual', 'organization'
  #   :individual_institution_name
  #   # :individual_name => Not in schema, this is data_user
  #   :individual_title
  #   :individual_telephone
  #   :individual_fax
  #   # :individual_email => Not in schema, this is agreement.user.email
  #   :individual_address

  #   :organization_business_name
  #   :organization_contact_name
  #   :organization_contact_title
  #   :organization_contact_telephone
  #   :organization_contact_fax
  #   :organization_contact_email
  #   :organization_address

  # STEP 2 Fields:
  #   :specific_purpose

  # STEP 3 Fields:
  #   :has_read_step3

  # Step 4 Fields:
  #   :posting_permission 'all', 'name_only', 'none'

  # STEP 5 Fields
  #   :has_read_step5

  serialize :history, Array

  mount_uploader :dua, PDFUploader
  mount_uploader :executed_dua, PDFUploader
  mount_uploader :irb, PDFUploader

  STATUS = ["submitted", "approved", "resubmit", "expired"].collect{|i| [i,i]}

  # Concerns
  include Deletable

  # Named Scopes
  scope :search, lambda { |arg| where( 'agreements.user_id in (select users.id from users where LOWER(users.first_name) LIKE ? or LOWER(users.last_name) LIKE ? or LOWER(users.email) LIKE ? )', arg.to_s.downcase.gsub(/^| |$/, '%'), arg.to_s.downcase.gsub(/^| |$/, '%'), arg.to_s.downcase.gsub(/^| |$/, '%') ).references(:users) }

  # Model Validation
  validates_presence_of :user_id
  # validates_presence_of :dua
  # validates_presence_of :executed_dua, if: :approved?
  validates_presence_of :comments, if: :resubmission_required?

  validates_presence_of :data_user, if: :step1?
  validates_presence_of :data_user_type, if: :step1?
  validates :data_user_type, inclusion: { in: %w(individual organization), message: "\"%{value}\" is not a valid data user type" }, if: :step1?
  validates_presence_of :individual_institution_name, :individual_title, :individual_telephone, :individual_fax, :individual_address, if: :step1_and_individual?
  validates_presence_of :organization_business_name, :organization_contact_name, :organization_contact_title, :organization_contact_telephone, :organization_contact_fax, :organization_contact_email, :organization_address, if: :step1_and_organization?

  validates_presence_of :specific_purpose, if: :step2?

  validates_presence_of :has_read_step3, if: :step3?

  validates_presence_of :posting_permission, if: :step4?
  validates :posting_permission, inclusion: { in: %w(all name_only none), message: "\"%{value}\" is not a valid posting permission" }, if: :step4?

  validates_presence_of :has_read_step5, if: :step5?

  validates_presence_of :signature, :signature_print, :signature_date, if: :step6?

  validates_presence_of :irb_evidence_type, if: :step7?
  validates :irb_evidence_type, inclusion: { in: %w(has_evidence no_evidence), message: "\"%{value}\" is not a valid evidence type" }, if: :step7?

  validates_presence_of :irb, if: :step7_and_has_evidence?

  # Model Relationships
  belongs_to :user

  # Agreement Methods

  def signature_valid_length?
    # eval($("#signature").val()).length > 20
  end

  def name
    self.user ? self.user.name : "##{self.id}"
  end

  def approved?
    self.status == 'approved'
  end

  def resubmission_required?
    self.status == 'resubmit' or self.status == 'expired'
  end

  def add_event!(message, current_user, status)
    self.history << { message: message, user_id: current_user.id, event_at: Time.now, status: status }
    self.status = status
    self.save
  end

  def daua_approved_email(current_user)
    self.add_event!('Data Access and Use Agreement approved.', current_user, 'approved')
    UserMailer.daua_approved(self, current_user).deliver if Rails.env.production?
    notify_admins_on_daua_progress(current_user)
  end

  def sent_back_for_resubmission_email(current_user)
    self.add_event!('Data Access and Use Agreement sent back for resubmission.', current_user, 'resubmit')
    UserMailer.sent_back_for_resubmission(self, current_user).deliver if Rails.env.production?
    notify_admins_on_daua_progress(current_user)
  end

  def notify_admins_on_daua_progress(current_user)
    other_admins = User.system_admins.where.not( id: current_user.id )
    other_admins.each do |admin|
      UserMailer.daua_progress_notification(self, admin).deliver if Rails.env.production?
    end
  end

  def daua_submitted
    User.system_admins.each do |system_admin|
      UserMailer.daua_submitted(system_admin, self).deliver if Rails.env.production?
    end
  end

  def step_valid?(step)
    dup_agreement = self.dup
    dup_agreement.current_step = step
    dup_agreement.valid?
  end

  protected

  def step1?
    self.current_step == 1
  end

  def step1_and_individual?
    self.step1? and self.data_user_type == 'individual'
  end

  def step1_and_organization?
    self.step1? and self.data_user_type == 'organization'
  end

  def step2?
    self.current_step == 2
  end

  def step3?
    self.current_step == 3
  end

  def step4?
    self.current_step == 4
  end

  def step5?
    self.current_step == 5
  end

  def step6?
    self.current_step == 6
  end

  def step7?
    self.current_step == 7
  end

  def step7_and_has_evidence?
    self.step7? and self.irb_evidence_type == 'has_evidence'
  end

end

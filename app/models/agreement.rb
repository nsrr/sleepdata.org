# frozen_string_literal: true

# Allows users to request access to one or more datasets.
class Agreement < ApplicationRecord
  # STEP 1 Fields:
  #   :data_user
  #   :data_user_type => 'individual', 'organization'
  #   :individual_institution_name
  #   # :individual_name => Not in schema, this is data_user
  #   :individual_title
  #   :individual_telephone
  #   # :individual_email => Not in schema, this is agreement.user.email
  #   :individual_address

  #   :organization_business_name
  #   :organization_contact_name
  #   :organization_contact_title
  #   :organization_contact_telephone
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

  mount_uploader :dua, PDFUploader
  mount_uploader :executed_dua, PDFUploader
  mount_uploader :irb, PDFUploader
  mount_uploader :printed_file, PDFUploader

  # Callbacks
  after_create_commit :set_token

  STATUS = %w(started submitted approved resubmit expired closed).collect { |i| [i, i] }

  attr_accessor :draft_mode, :full_mode

  # Concerns
  include Deletable, Latexable, Forkable

  # Named Scopes
  scope :search, lambda { |arg| where( 'agreements.user_id in (select users.id from users where LOWER(users.first_name) LIKE ? or LOWER(users.last_name) LIKE ? or LOWER(users.email) LIKE ? )', arg.to_s.downcase.gsub(/^| |$/, '%'), arg.to_s.downcase.gsub(/^| |$/, '%'), arg.to_s.downcase.gsub(/^| |$/, '%') ).references(:users) }
  scope :expired, -> { where("agreements.expiration_date IS NOT NULL and agreements.expiration_date < ?", Date.today) }
  scope :not_expired, -> { where("agreements.expiration_date IS NULL or agreements.expiration_date >= ?", Date.today) }
  scope :with_tag, lambda { |arg| where('agreements.id in (select agreement_tags.agreement_id from agreement_tags where agreement_tags.tag_id = ?)', arg).references(:agreement_tags) }
  scope :regular_members, -> { where("agreements.user_id in (select users.id from users where users.deleted = ? and users.aug_member = ? and users.core_member = ?)", false, false, false).references(:users) }
  scope :submittable, -> { where(status: %w(started resubmit)) }
  scope :deletable, -> { where(status: %w(started resubmit closed)) }

  # Model Validation
  validates :user_id, :status, presence: true
  validates :duly_authorized_representative_token, uniqueness: true, allow_nil: true

  validates :reviewer_signature, :approval_date, :expiration_date, presence: true, if: :approved?
  # validates :reviewer_signature, length: { minimum: 20, tokenizer: lambda { |str| (JSON.parse(str) rescue []) }, too_short: "can't be blank" }, if: :approved?
  validates :edges_in_reviewer_signature, length: { minimum: 20, too_short: "can't be blank" }, if: :approved?

  validates :comments, presence: true, if: :resubmission_required?

  validates :data_user, presence: true, if: :step1?
  validates :data_user_type, presence: true, if: :step1?
  validates :data_user_type, inclusion: { in: %w(individual organization), message: '"%{value}" is not a valid data user type' }, if: :step1?
  validates :individual_institution_name, :individual_title, :individual_telephone, :individual_address, presence: true, if: :step1_and_individual?
  validates :organization_business_name, :organization_contact_name, :organization_contact_title, :organization_contact_telephone, :organization_contact_email, :organization_address, presence: true, if: :step1_and_organization?

  validates :title_of_project, :specific_purpose, presence: true, if: :step2?
  validates :words_in_specific_purpose, length: { minimum: 20, too_short: 'is lacking sufficient detail and must be at least %{count} words.' }, if: :step2?
  validates :datasets, presence: true, if: :step2?
  validates :intended_use_of_data, :data_secured_location, :secured_device, :human_subjects_protections_trained, presence: true, if: :step2?

  validates :has_read_step3, presence: true, if: :step3?
  validates :posting_permission, presence: true, if: :step3?
  validates :posting_permission, inclusion: { in: %w(all name_only none), message: '"%{value}" is not a valid posting permission' }, if: :step3?

  validates :signature, :signature_print, :signature_date, presence: true, if: :step4_and_authorized?
  validates :edges_in_signature, length: { minimum: 20, too_short: "can't be blank" }, if: :step4_and_authorized?

  validates :duly_authorized_representative_signature, :duly_authorized_representative_signature_print, :duly_authorized_representative_signature_date, :duly_authorized_representative_title, presence: true, if: :step4_and_not_authorized?
  validates :edges_in_duly_authorized_representative_signature, length: { minimum: 20, too_short: "can't be blank" }, if: :step4_and_not_authorized?

  validates :irb_evidence_type, presence: true, if: :step5?
  validates :irb_evidence_type, inclusion: { in: %w(has_evidence no_evidence), message: '"%{value}" is not a valid evidence type' }, if: :step5?

  validates :irb, presence: true, if: :step5_and_has_evidence?

  # Model Relationships
  belongs_to :user
  has_many :requests
  has_many :datasets, -> { where deleted: false }, through: :requests
  has_many :reviews, -> { joins(:user).order('lower(substring(users.first_name from 1 for 1)), lower(substring(users.last_name from 1 for 1))') }
  has_many :agreement_events, -> { order(:event_at) }
  has_many :agreement_tags
  has_many :tags, -> { where(deleted: false).order(:name) }, through: :agreement_tags
  has_many :agreement_transactions, -> { order(id: :desc) }
  has_many :agreement_transaction_audits

  # Agreement Methods

  def copyable_attributes
    ignore_list = %w(id deleted created_at updated_at reviewer_signature
                     approval_date expiration_date comments has_read_step3
                     has_read_step5 current_step dua executed_dua)
    attributes.reject { |key, _val| ignore_list.include?(key.to_s) }
  end

  def dataset_ids=(ids)
    self.datasets = Dataset.where(id: ids)
  end

  def name
    user ? user.name : "##{id}"
  end

  def name_with_id
    user ? "##{id} - #{user.name}" : "##{id}"
  end

  def to_param
    id.to_s + (user ? "-#{user.name.parameterize}" : '')
  end

  def id_and_representative_token
    "#{id}-#{duly_authorized_representative_token}"
  end

  def agreement_number
    Agreement.where(user_id: user_id).order(:id).pluck(:id).index(id) + 1
  end

  def approved?
    status == 'approved'
  end

  def under_review?
    status == 'submitted'
  end

  def resubmission_required?
    status == 'resubmit'
  end

  def resubmitted?
    resubmitted_at.present?
  end

  def academic?
    data_user_type == 'individual'
  end

  def commercial?
    data_user_type == 'organization'
  end

  def close_daua!(current_user)
    agreement_events.create event_type: 'principal_reviewer_closed', user_id: current_user.id, event_at: Time.zone.now
  end

  def expire_daua!(current_user)
    agreement_events.create event_type: 'principal_reviewer_expired', user_id: current_user.id, event_at: Time.zone.now
  end

  def daua_approved_email(current_user)
    agreement_event = agreement_events.create event_type: 'principal_reviewer_approved', user_id: current_user.id, event_at: Time.zone.now
    reviews.where(approved: nil).destroy_all
    daua_approved_send_emails_in_background(current_user, agreement_event)
  end

  def daua_approved_send_emails_in_background(current_user, agreement_event)
    fork_process(:daua_approved_send_emails, current_user, agreement_event)
  end

  def daua_approved_send_emails(current_user, agreement_event)
    UserMailer.daua_approved(self, current_user).deliver_now if EMAILS_ENABLED
    notify_admins_on_daua_progress(current_user, agreement_event)
  end

  def sent_back_for_resubmission_email(current_user)
    agreement_event = agreement_events.create(
      event_type: 'principal_reviewer_required_resubmission',
      user_id: current_user.id, event_at: Time.zone.now, comment: comments
    )
    daua_ask_for_resubmit_send_emails_in_background(current_user, agreement_event)
  end

  def daua_ask_for_resubmit_send_emails_in_background(current_user, agreement_event)
    fork_process(:daua_ask_for_resubmit_send_emails, current_user, agreement_event)
  end

  def daua_ask_for_resubmit_send_emails(current_user, agreement_event)
    UserMailer.sent_back_for_resubmission(self, current_user).deliver_now if EMAILS_ENABLED
    notify_admins_on_daua_progress(current_user, agreement_event)
  end

  def notify_admins_on_daua_progress(current_user, agreement_event)
    other_admins = User.system_admins.where.not(id: current_user.id)
    other_admins.each do |admin|
      UserMailer.daua_progress_notification(self, admin, agreement_event).deliver_now if EMAILS_ENABLED
    end
  end

  def daua_submitted_in_background
    fork_process(:daua_submitted)
  end

  def daua_submitted
    add_reviewers!
    reviews.each do |review|
      UserMailer.daua_submitted(review.user, self).deliver_now if EMAILS_ENABLED
    end
  end

  def add_reviewers!
    reviewers = User.current.where(id: datasets.collect { |d| d.reviewers.pluck(:id) }.flatten.uniq.compact)
    reviewers.each do |reviewer|
      reviews.where(user_id: reviewer.id).first_or_create
    end
  end

  def step_valid?(step)
    dup_agreement = dup
    dup_agreement.duly_authorized_representative_token = nil
    dup_agreement.current_step = step
    dup_agreement.irb = irb
    dup_agreement.datasets = datasets
    dup_agreement.valid?
  end

  def draft_mode?
    draft_mode.to_s == '1'
  end

  def full_mode?
    full_mode.to_s == '1'
  end

  def fully_filled_out?
    self.full_mode = '1'
    valid?
  end

  def latex_partial(partial)
    File.read(File.join('app', 'views', 'agreements', 'latex', "_#{partial}.tex.erb"))
  end

  def generate_printed_pdf!
    jobname = "agreement_#{id}"
    output_folder = Rails.root.join('tmp', 'files', 'tex')
    FileUtils.mkdir_p output_folder
    file_tex = Rails.root.join('tmp', 'files', 'tex', jobname + '.tex')
    create_signature_pngs
    @agreement = self # Needed by Binding

    File.open(file_tex, 'w') do |file|
      file.syswrite(ERB.new(latex_partial('header')).result(binding))
      file.syswrite(ERB.new(latex_partial('body')).result(binding))
      file.syswrite(ERB.new(latex_partial('footer')).result(binding))
    end

    file_name = Agreement.generate_pdf(jobname, output_folder, file_tex)
    return unless File.exist? file_name
    self.printed_file = File.open(file_name)
    save(validate: false)
  end

  def create_signature_pngs
    folder = Rails.root.join('tmp', 'files', 'agreements', "#{id}")
    FileUtils.mkpath folder
    Agreement.create_signature_png(signature, File.join(folder, 'signature.png'))
    Agreement.create_signature_png(duly_authorized_representative_signature, File.join(folder, 'duly_authorized_representative_signature.png'))
    Agreement.create_signature_png(reviewer_signature, File.join(folder, 'reviewer_signature.png'))
  end

  def self.create_signature_png(signature, filename)
    canvas = ChunkyPNG::Canvas.new(300, 55)
    (JSON.parse(signature) rescue []).each do |hash|
      canvas.line(hash['mx'], hash['my'], hash['lx'], hash['ly'], ChunkyPNG::Color.parse('#145394'))
    end
    png = canvas.to_image
    png.save(filename)
  end

  def duly_authorized_representative_valid?
    duly_authorized_representative_signature.present? && duly_authorized_representative_signature_print.present? && duly_authorized_representative_signature_date.present? && duly_authorized_representative_title.present?
  end

  def send_daua_signed_email_in_background
    fork_process(:send_daua_signed_email)
  end

  def send_daua_signed_email
    UserMailer.daua_signed(self).deliver_now if EMAILS_ENABLED
  end

  def authorized_signature_date
    unauthorized_to_sign? ? duly_authorized_representative_signature_date : signature_date
  end

  protected

  def save_mode?
    !draft_mode?
  end

  def validate_step?(step)
    full_mode? || (current_step == step && save_mode?)
  end

  def step1?
    validate_step?(1)
  end

  def step1_and_individual?
    data_user_type == 'individual' && step1?
  end

  def step1_and_organization?
    data_user_type == 'organization' && step1?
  end

  def step2?
    validate_step?(2)
  end

  def step3?
    validate_step?(3)
  end

  def step4?
    validate_step?(4)
  end

  def step4_and_authorized?
    unauthorized_to_sign == false && step4?
  end

  def step4_and_not_authorized?
    unauthorized_to_sign == true && step4?
  end

  def step5?
    validate_step?(5)
  end

  def step5_and_has_evidence?
    irb_evidence_type == 'has_evidence' && step5?
  end

  def self.latex_safe(mystring)
    new.latex_safe(mystring)
  end

  private

  def set_token
    return unless duly_authorized_representative_token.blank?
    update duly_authorized_representative_token: SecureRandom.hex(12)
  rescue ActiveRecord::RecordNotUnique, ActiveRecord::RecordInvalid
    retry
  end

  def edges_in_reviewer_signature
    JSON.parse(reviewer_signature)
  rescue
    []
  end

  def edges_in_signature
    JSON.parse(signature)
  rescue
    []
  end

  def edges_in_duly_authorized_representative_signature
    JSON.parse(duly_authorized_representative_signature)
  rescue
    []
  end

  def words_in_specific_purpose
    specific_purpose.to_s.scan(/\w+/)
  end
end

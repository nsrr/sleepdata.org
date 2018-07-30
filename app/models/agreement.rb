# frozen_string_literal: true

# Allows users to request access to one or more datasets.
class Agreement < ApplicationRecord
  mount_uploader :printed_file, PDFUploader

  mount_uploader :signature_file, SignatureUploader
  mount_uploader :duly_authorized_representative_signature_file, SignatureUploader
  mount_uploader :reviewer_signature_file, SignatureUploader

  # Callbacks
  after_create_commit :set_token

  STATUS = %w(started submitted approved resubmit expired closed).collect { |i| [i, i] }

  attr_accessor :draft
  attr_accessor :representative

  # Concerns
  include Deletable
  include Latexable
  include Forkable

  # Scopes
  scope :search, ->(arg) { joins(:user).merge(User.search(arg)) }
  scope :expired, -> { where("expiration_date < ?", Time.zone.today) }
  scope :not_expired, -> { where(expiration_date: nil).or(where("expiration_date >= ?", Time.zone.today)) }
  scope :with_tag, ->(arg) { joins(:tags).merge(Tag.current.where(id: arg)) }
  scope :with_vote, ->(arg) { joins(:data_request_reviews).merge(DataRequestReview.where(user: arg, vote_cleared: false, approved: [true, false])) }
  scope :without_vote, ->(arg) { where(status: "submitted").left_outer_joins(:data_request_reviews).where("data_request_reviews.user_id = ? and (vote_cleared = ? or approved IS NULL)", arg, true) }
  scope :regular_members, -> { joins(:user).merge(User.current.where(aug_member: false, core_member: false)) }
  scope :submittable, -> { where(status: %w(started resubmit)) }
  scope :deletable, -> { where(status: %w(started resubmit closed)) }

  # Validations
  validates :status, presence: true
  validates :duly_authorized_representative_token, uniqueness: true, allow_nil: true
  validates :approval_date, :expiration_date, presence: true, if: :approved?
  validates :comments, presence: true, if: :resubmission_required?

  validates :duly_authorized_representative_signature_print, presence: true, if: :representative?
  validates :duly_authorized_representative_title, presence: true, if: :representative?

  # Relationships
  belongs_to :user
  belongs_to :final_legal_document
  has_many :agreement_variables
  has_many :requests
  has_many :datasets, -> { current }, through: :requests
  has_many :data_request_reviews, -> { joins(:user).order(Arel.sql("users.full_name")) }, foreign_key: "data_request_id"
  has_many :agreement_events, -> { order(:event_at) }
  has_many :agreement_tags
  has_many :tags, -> { current.order(:name) }, through: :agreement_tags
  has_many :agreement_transactions, -> { order(id: :desc) }
  has_many :agreement_transaction_audits

  delegate :organization, to: :final_legal_document

  # Methods

  def dataset_ids=(ids)
    self.datasets = Dataset.where(id: ids)
  end

  def name
    "Data Request ##{id}"
  end

  def id_and_representative_token
    "#{id}-#{duly_authorized_representative_token}"
  end

  def user_full_name_or_email
    full_name = \
      agreement_variables
      .joins(:final_legal_document_variable)
      .merge(FinalLegalDocumentVariable.where(name: "full_name"))
      .first&.value
    full_name.presence || user.email
  end

  def agreement_number
    Agreement.where(user_id: user_id).order(:id).pluck(:id).index(id) + 1
  end

  def approved?
    status == "approved"
  end

  def submitted?
    status == "submitted"
  end

  def resubmission_required?
    status == "resubmit"
  end

  def resubmitted?
    resubmitted_at.present?
  end

  def submittable?
    %w(started resubmit).include?(status)
  end

  def deletable?
    %w(closed started resubmit).include?(status)
  end

  def close_daua!(current_user)
    agreement_events.create(
      event_type: "principal_reviewer_closed",
      user: current_user,
      event_at: Time.zone.now
    )
  end

  def expire_daua!(current_user)
    agreement_events.create(
      event_type: "principal_reviewer_expired",
      user: current_user,
      event_at: Time.zone.now
    )
  end

  def daua_approved_email(current_user)
    agreement_event = agreement_events.create(
      event_type: "principal_reviewer_approved",
      user: current_user,
      event_at: Time.zone.now
    )
    data_request_reviews.where(approved: nil).destroy_all
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
      event_type: "principal_reviewer_required_resubmission",
      user: current_user,
      event_at: Time.zone.now,
      comment: comments
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
    other_admins = User.admins.where.not(id: current_user.id)
    other_admins.each do |admin|
      UserMailer.daua_progress_notification(self, admin, agreement_event).deliver_now if EMAILS_ENABLED
    end
  end

  def daua_submitted_in_background
    fork_process(:daua_submitted)
  end

  def daua_submitted
    if final_legal_document.approval_process == "immediate"
      auto_approve!
    else
      add_reviewers!
      data_request_reviews.each do |review|
        UserMailer.daua_submitted(review.user, self).deliver_now if EMAILS_ENABLED
      end
    end
  end

  def add_reviewers!
    reviewers = final_legal_document.organization.reviewers
    reviewers.each do |reviewer|
      data_request_reviews.where(user_id: reviewer.id).first_or_create
    end
    data_request_reviews.where.not(approved: nil).update_all(vote_cleared: true)
  end

  def auto_approve!
    current_time = Time.zone.now
    AgreementTransaction.save_agreement!(
      self, user, "127.0.0.1", "agreement_update",
      data_request_params: {
        status: "approved",
        approval_date: current_time,
        expiration_date: current_time + 1.year
      }
    )
    agreement_events.create(event_type: "auto_approved", user: user, event_at: current_time)
  end

  def draft?
    draft.to_s == "1"
  end

  def representative?
    representative.to_s == "1"
  end

  def smart_status
    case status
    when "approved"
      if expiration_date && expiration_date < Time.zone.today
        "expired"
      else
        "approved"
      end
    else
      status
    end
  end

  def latex_partial(partial)
    file_path = Rails.root.join("app", "views", "data_requests", "print", "_#{partial}.tex.erb")
    # puts "latex_partial: [#{File.exist?(file_path) ? "X" : " "}] \"#{file_path}\"" if ENV["TRAVIS"]
    File.read(file_path)
  end

  def generate_printed_pdf!
    jobname = "data_request_#{id}"
    output_folder = Rails.root.join("tmp", "files", "tex")
    FileUtils.mkdir_p output_folder
    file_tex = Rails.root.join("tmp", "files", "tex", jobname + ".tex")
    @data_request = self # Needed by Binding

    File.open(file_tex, "w") do |file|
      file.syswrite(ERB.new(latex_partial("header")).result(binding))
      final_legal_document.final_legal_document_pages.each do |final_legal_document_page|
        file.syswrite(ERB.new(latex_partial("final_legal_document_page")).result(binding))
      end
      file.syswrite(ERB.new(latex_partial("footer")).result(binding))
    end

    file_name = DataRequest.generate_pdf(jobname, output_folder, file_tex)
    return unless File.exist? file_name
    self.printed_file = File.open(file_name)
    save(validate: false)
  end

  def authorized_signature_date
    representative_designated? ? (duly_authorized_representative_signed_at || duly_authorized_representative_signature_date) : (attested_at || signature_date)
  end

  def save_signature!(attribute, data_uri)
    file = Tempfile.new("#{attribute}.png")
    begin
      encoded_image = data_uri.split(",")[1]
      decoded_image = Base64.decode64(encoded_image)
      File.open(file, "wb") { |f| f.write(decoded_image) }
      file.define_singleton_method(:original_filename) do
        "#{attribute}.png"
      end
      send("#{attribute}=", file)
      save
    ensure
      file.close
      file.unlink # deletes the temp file
    end
  end

  def self.latex_safe(mystring)
    new.latex_safe(mystring)
  end

  private

  def set_token
    return if duly_authorized_representative_token.present?
    update duly_authorized_representative_token: SecureRandom.hex(12)
  rescue ActiveRecord::RecordNotUnique, ActiveRecord::RecordInvalid
    retry
  end
end

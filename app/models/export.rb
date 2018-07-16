# frozen_string_literal: true

# Allows organization owners to export data request spreadsheets.
class Export < ApplicationRecord
  # Constants
  STATUS = %w(started completed failed).collect { |i| [i, i] }

  # Uploaders
  mount_uploader :zipped_file, ZipUploader

  # Concerns
  include Deletable
  include Forkable

  # Validations
  validates :name, presence: true

  # Relationships
  belongs_to :user
  belongs_to :organization
  has_many :notifications

  # Methods

  def destroy
    remove_zipped_file!
    super
  end

  def percent
    return 100 unless total_steps.positive?
    completed_steps * 100 / total_steps
  end

  def create_notification
    notification = user.notifications.where(organization_id: organization_id, export_id: id).first_or_create
    notification.mark_as_unread!
  end

  def generate_export_in_background!
    update(total_steps: organization.final_legal_documents.sum { |doc| doc.final_legal_document_variables.size })
    fork_process(:generate_export!)
  end

  def generate_export!
    all_files = []
    organization.final_legal_documents.find_each do |final_legal_document|
      all_files << generate_csv_for_final_legal_document(final_legal_document)
    end
    finalize_export!(all_files)
  rescue => e
    export_failed(e.message.to_s + e.backtrace.to_s)
  end

  def finalize_export!(all_files)
    # Create a zip file
    zip_name = "data-requests-#{Time.zone.now.strftime("%Y-%m-%d")}.zip"
    temp_zip_file = Tempfile.new(zip_name)
    begin
      # Initialize temp zip file.
      Zip::OutputStream.open(temp_zip_file) { |zos| }
      # Write to temp zip file.
      Zip::File.open(temp_zip_file, Zip::File::CREATE) do |zip|
        all_files.uniq.each do |location, input_file|
          # Two arguments:
          # - The name of the file as it will appear in the archive
          # - The original file, including the path to find it
          zip.add(location, input_file) if File.exist?(input_file) && File.size(input_file).positive?
        end
      end
      temp_zip_file.define_singleton_method(:original_filename) do
        zip_name
      end
      update(
        zipped_file: temp_zip_file,
        file_created_at: Time.zone.now,
        status: "completed",
        completed_steps: total_steps
      )
      update file_size: zipped_file.size # Cache after attaching to model.
      create_notification
    ensure
      # Close and delete the temp file
      temp_zip_file.close
      temp_zip_file.unlink
    end
  end

  def export_failed(details)
    update(status: "failed", details: details)
    create_notification
  end

  def generate_csv_for_final_legal_document(final_legal_document)
    csv_name = "#{final_legal_document.slug}-#{final_legal_document.version}.csv"
    temp_csv_file = Tempfile.new("#{final_legal_document.slug}-#{final_legal_document.version}-inverted.csv")
    transposed_csv_file = Tempfile.new(csv_name)
    data_request_ids = final_legal_document.data_request_ids
    data_request_scope = DataRequest.where(id: data_request_ids).order(:id)
    CSV.open(temp_csv_file, "wb") do |csv|
      csv << ["DataRequestID"] + data_request_scope.pluck(:id)
      csv << ["Status"] + data_request_scope.pluck(:status)
      csv << ["Last Submitted"] + data_request_scope.pluck(:last_submitted_at)
      csv << ["Approval Date"] + data_request_scope.pluck(:approval_date)
      csv << ["Expiration Date"] + data_request_scope.pluck(:expiration_date)
      csv << ["Approved By"] + data_request_scope.includes(data_request_reviews: :user).collect { |a| a.data_request_reviews.select { |r| r.approved == true }.collect { |r| r.user.initials }.join(",") }
      csv << ["Rejected By"] + data_request_scope.includes(data_request_reviews: :user).collect { |a| a.data_request_reviews.select { |r| r.approved == false }.collect { |r| r.user.initials }.join(",") }
      final_legal_document.final_legal_document_pages.each do |final_legal_document_page|
        final_legal_document_page.variables.each do |variable|
          csv << [variable.display_name_label] + data_request_scope.includes(:agreement_variables).where(agreement_variables: { final_legal_document_variable: variable }).collect { |a| a.agreement_variables.first&.value }
          update(completed_steps: completed_steps + 1)
        end
      end
      csv << ["Signature Print"] + data_request_scope.pluck(:signature_print)
      csv << ["Signature Date"] + data_request_scope.pluck(:signature_date)
      csv << ["Representative Designated"] + data_request_scope.collect(&:representative_designated?)
      csv << ["Duly Authorized Representative Email"] + data_request_scope.pluck(:duly_authorized_representative_email)
      csv << ["Duly Authorized Representative Signature Print"] + data_request_scope.pluck(:duly_authorized_representative_signature_print)
      csv << ["Duly Authorized Representative Title"] + data_request_scope.pluck(:duly_authorized_representative_title)
      csv << ["Duly Authorized Representative Signature Date"] + data_request_scope.pluck(:duly_authorized_representative_signature_date)
      Tag.review_tags.order(:name).each do |tag|
        csv << [tag.name] + data_request_scope.includes(:agreement_tags).collect { |a| a.agreement_tags.select { |at| at.tag_id == tag.id }.present? ? tag.name : "" }
      end
    end
    transpose_tmp_csv(temp_csv_file, transposed_csv_file)
    ["#{organization.slug}/#{csv_name}", transposed_csv_file]
  end

  def transpose_tmp_csv(temp_csv_file, transposed_csv_file)
    arr_of_arrs = CSV.parse(File.open(temp_csv_file, "r:iso-8859-1:utf-8", &:read))
    l = arr_of_arrs.map(&:length).max
    arr_of_arrs.map! { |e| e.values_at(0...l) }
    CSV.open(transposed_csv_file, "wb") do |csv|
      arr_of_arrs.transpose.each do |array|
        csv << array
      end
    end
  end
end

# frozen_string_literal: true

# A published and versioned legal document page. Not editable.
class FinalLegalDocumentPage < ApplicationRecord
  # Concerns
  include Deletable

  # Validations
  validates :title, :position, presence: true

  # Relationships
  belongs_to :final_legal_document

  alias_method :legal_document, :final_legal_document

  # Methods
  def readable_content
    content.to_s.gsub(/\#{(\d+)}/) do
      v = final_legal_document.final_legal_document_variables.find_by(id: $1)
      if v
        "<#{v.name}#{":#{v.variable_type}" unless v.variable_type == "string"}>"
      else
        "\#{#{$1}}"
      end
    end
  end

  def content=(content)
    content = content.to_s.gsub(/\<([\w\:]+)\>/m) { |m| variable_creation($1) } if final_legal_document
    self[:content] = content.try(:strip)
  end

  alias_method :readable_content=, :content=

  def variable_creation(name_string)
    (variable_name, variable_type) = name_string.split(":")
    variable_type = "string" unless LegalDocumentVariable::VARIABLE_TYPES.collect(&:second).include?(variable_type)
    v = final_legal_document.final_legal_document_variables.where(name: variable_name).first_or_create(variable_type: variable_type)
    if v
      "\#{#{v.id}}"
    else
      "<#{name_string}>"
    end
  end

  def readable_content_text_only
    readable_content.gsub(/<(.*?)>/, "")
  end

  def readable_content_for_major_comparison
    readable_content_text_only.downcase
  end

  def readable_content_for_minor_comparison
    readable_content_text_only.gsub(/\s/, " ")
  end
end

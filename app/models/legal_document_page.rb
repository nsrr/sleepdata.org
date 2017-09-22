# frozen_string_literal: true

# Defines the content of a page of the legal document.
class LegalDocumentPage < ApplicationRecord
  # Concerns
  include Deletable
  include Searchable

  # Validations
  validates :title, :content, presence: true

  # Relationships
  belongs_to :legal_document

  # Methods
  def self.searchable_attributes
    %w(title content)
  end

  def readable_content
    content.to_s.gsub(/\#{(\d+)}/) do
      v = legal_document.legal_document_variables.find_by(id: $1)
      if v
        "<#{v.name}#{":#{v.variable_type}" unless v.variable_type == "string"}>"
      else
        "\#{#{$1}}"
      end
    end
  end

  def content=(content)
    content = content.to_s.gsub(/\<([\w\:]+)\>/m) { |m| variable_creation($1) } if legal_document
    self[:content] = content.try(:strip)
  end

  alias_method :readable_content=, :content=

  def variable_creation(name_string)
    (variable_name, variable_type) = name_string.split(":")
    variable_type = "string" unless LegalDocumentVariable::VARIABLE_TYPES.collect(&:second).include?(variable_type)
    v = legal_document.legal_document_variables.where(name: variable_name).first_or_create(variable_type: variable_type)
    if v
      "\#{#{v.id}}"
    else
      "<#{name_string}>"
    end
  end
end

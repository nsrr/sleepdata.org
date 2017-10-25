module LegalDocumentsHelper
  def legal_markdown(legal_document_page, editable: false, reviewer: false)
    result = legal_document_page.content.to_s
    result = replace_outline_variables(result, legal_document_page.legal_document, editable, reviewer)
    result = replace_inline_variables(result, legal_document_page.legal_document, editable, reviewer)
    result = replace_numbers_with_ascii(result)
    result = redcarpet_markdown.render(result)
    result = result.encode("UTF-16", undef: :replace, invalid: :replace, replace: "").encode("UTF-8")
    result.html_safe
  end

  def replace_outline_variables(text, legal_document, editable, reviewer)
    text.gsub(/[^ ]\#{(\d+)}/m) { |m| insert_outline_variable($1, legal_document, editable, reviewer) }
  end

  def insert_outline_variable(variable_id, legal_document, editable, reviewer)
    variable = legal_document.legal_document_variables.find_by(id: variable_id)
    if variable
      render "legal_documents/outline/form", variable: variable, editable: editable, reviewer: reviewer
    else
      " \#{#{variable_id}}"
    end
  end

  def replace_inline_variables(text, legal_document, editable, reviewer)
    text.gsub(/\#{(\d+)}/m) { |m| insert_inline_variable($1, legal_document, editable, reviewer) }
  end

  def insert_inline_variable(variable_id, legal_document, editable, reviewer)
    variable = legal_document.legal_document_variables.find_by(id: variable_id)
    if variable
      render "legal_documents/inline/form", variable: variable, editable: editable, reviewer: reviewer
    else
      " \#{#{variable_id}}"
    end
  end
end

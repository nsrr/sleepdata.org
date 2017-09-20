# frozen_string_literal: true

require "test_helper"

# Test that organization editors can create and modify legal document variables.
class LegalDocumentVariablesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @organization = organizations(:one)
    @legal_document = legal_documents(:one)
    @legal_document_variable = legal_document_variables(:one)
    @admin = users(:admin)
  end

  def legal_document_variable_params
    {
      position: "1",
      name: "updated_name",
      variable_type: "checkbox",
      display_name: "Updated Name",
      description: "Please check this check box.",
      field_note: "Field note info.",
      required: "0"
    }
  end

  # test "should get index" do
  #   login(@admin)
  #   get organization_legal_document_legal_document_variables_url(@organization, @legal_document)
  #   assert_response :success
  # end

  # test "should get new" do
  #   login(@admin)
  #   get new_organization_legal_document_legal_document_variable_url(@organization, @legal_document)
  #   assert_response :success
  # end

  # test "should create legal document variable" do
  #   login(@admin)
  #   assert_difference("LegalDocumentVariable.count") do
  #     post organization_legal_document_legal_document_variables_url(@organization, @legal_document), params: { legal_document_variable: legal_document_variable_params }
  #   end
  #   assert_equal "Provide more information:\n<more_information>", LegalDocumentVariable.last.readable_content
  #   assert_redirected_to organization_legal_document_legal_document_variable_url(@organization, @legal_document, LegalDocumentVariable.last)
  # end

  # test "should show legal document variable" do
  #   login(@admin)
  #   get organization_legal_document_legal_document_variable_url(@organization, @legal_document, @legal_document_variable)
  #   assert_response :success
  # end

  test "should get edit" do
    login(@admin)
    get edit_organization_legal_document_legal_document_variable_url(
      @organization, @legal_document, @legal_document_variable, format: "js"
    ), xhr: true
    assert_template "edit"
    assert_response :success
  end

  test "should update legal document variable" do
    login(@admin)
    patch organization_legal_document_legal_document_variable_url(
      @organization, @legal_document, @legal_document_variable, format: "js"
    ), params: { legal_document_variable: legal_document_variable_params }
    assert_template "show"
    assert_response :success
  end

  # test "should destroy legal document variable" do
  #   login(@admin)
  #   assert_difference("LegalDocumentVariable.current.count", -1) do
  #     delete organization_legal_document_legal_document_variable_url(@organization, @legal_document, @legal_document_variable)
  #   end
  #   assert_redirected_to organization_legal_document_legal_document_variables_url(@organization, @legal_document)
  # end
end

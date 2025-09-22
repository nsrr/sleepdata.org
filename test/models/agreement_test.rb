# frozen_string_literal: true

require "test_helper"

class AgreementTest < ActiveSupport::TestCase

  test "user_full_name_and_email returns full name and email when both are present" do
    agreement = Agreement.new

    mock_relation = Minitest::Mock.new
    mock_relation.expect :joins, mock_relation, [:final_legal_document_variable]
    mock_relation.expect :merge, mock_relation, [FinalLegalDocumentVariable.where(name: "full_name")]
    mock_relation.expect :first, OpenStruct.new(value: "Mocked Name")

    mock_user = OpenStruct.new(email: "mock@example.com")

    agreement.stub(:agreement_variables, mock_relation) do
      agreement.stub(:user, mock_user) do
        assert_equal "Mocked Name <mock@example.com>", agreement.user_full_name_and_email
      end
    end

    mock_relation.verify
  end

  test "user_full_name_and_email returns email when full name is not present" do
    agreement = Agreement.new

    mock_relation = Minitest::Mock.new
    mock_relation.expect :joins, mock_relation, [:final_legal_document_variable]
    mock_relation.expect :merge, mock_relation, [FinalLegalDocumentVariable.where(name: "full_name")]
    mock_relation.expect :first, OpenStruct.new(value: nil)

    mock_user = OpenStruct.new(email: "mock@example.com")

    agreement.stub(:agreement_variables, mock_relation) do
      agreement.stub(:user, mock_user) do
        assert_equal "mock@example.com", agreement.user_full_name_and_email
      end
    end

    mock_relation.verify
  end

end

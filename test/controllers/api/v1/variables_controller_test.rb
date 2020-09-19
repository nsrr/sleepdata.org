# frozen_string_literal: true

require "test_helper"

# Tests to assure that variables can be uploaded to datasets via the API.
class Api::V1::VariablesControllerTest < ActionDispatch::IntegrationTest
  def variable_params
    {
      name: "favorite_flavor",
      display_name: "Favorite Icecream Flavor",
      variable_type: "choices",
      labels: %w(food dessert)
    }
  end

  def domain_params
    {
      name: "flavors",
      folder: "",
      options: options_params,
      spout_version: "x.x.x"
    }
  end

  def options_params
    [
      {
        display_name: "Vanilla",
        value: "1"
      },
      {
        display_name: "Chocolate",
        value: "2",
        description: "",
        missing: false
      },
      {
        display_name: "Refused to answer",
        value: "-9",
        description: "Participant refused to answer.",
        missing: true
      }
    ]
  end

  def form_params
    {
      name: "market_survey",
      folder: "folder",
      display_name: "Market Survey",
      code_book: "market-survey.pdf",
      spout_version: "x.x.x"
    }
  end

  test "should get index" do
    get api_v1_variables_url(format: "json"), params: {
      auth_token: users(:editor).id_and_auth_token,
      version: "0.1.0",
      dataset: datasets(:released).to_param
    }
    assert_response :success
  end

  test "should get variable" do
    get api_v1_variable_url(variables(:one), format: "json"), params: {
      auth_token: users(:editor).id_and_auth_token,
      version: "0.1.0",
      dataset: datasets(:released).to_param
    }
    assert_response :success
  end

  test "should not get variable with invalid id" do
    get api_v1_variable_url("-1", format: "json"), params: {
      auth_token: users(:editor).id_and_auth_token,
      version: "0.1.0",
      dataset: datasets(:released).to_param
    }
    assert_response :unprocessable_entity
  end

  test "should create variable" do
    assert_difference("Variable.count") do
      assert_difference("Domain.count") do
        assert_difference("Form.count") do
          assert_difference("DomainOption.count", 3) do
            post create_or_update_api_v1_variables_url(format: "json"), params: {
              auth_token: users(:editor).id_and_auth_token,
              version: "0.1.0",
              dataset: datasets(:released).to_param,
              variable: variable_params,
              domain: domain_params,
              forms: [form_params]
            }
          end
        end
      end
    end
    assert_not_nil assigns(:variable)
    assert_equal %w(dessert food), assigns(:variable).variable_labels.pluck(:name).sort
    assert_response :success
  end

  test "should create variable form with invalid form name" do
    assert_difference("Form.count", 0) do
      post create_or_update_api_v1_variables_url(format: "json"), params: {
        auth_token: users(:editor).id_and_auth_token,
        version: "0.1.0",
        dataset: datasets(:released).to_param,
        variable: variable_params,
        domain: domain_params,
        forms: [form_params.merge(name: "")]
      }
    end
    assert_response :unprocessable_entity
  end

  test "should update existing variable and move folder" do
    post create_or_update_api_v1_variables_url(format: "json"), params: {
      auth_token: users(:editor).id_and_auth_token,
      version: "0.1.0",
      dataset: datasets(:released).to_param,
      variable: {
        name: "root",
        display_name: "Move out of root",
        variable_type: "string",
        labels: %w(root folder),
        folder: "Polysomnography (PSG)/Sleep Architecture"
      },
      domain: domain_params,
      forms: [form_params]
    }
    assert_equal "Polysomnography (PSG)/Sleep Architecture", assigns(:variable).folder
  end
end

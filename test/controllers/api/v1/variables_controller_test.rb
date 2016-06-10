# frozen_string_literal: true

require 'test_helper'

# Tests to assure that variables can be uploaded to datasets via the API.
class Api::V1::VariablesControllerTest < ActionController::TestCase
  def variable_params
    {
      name: 'favorite_flavor',
      display_name: 'Favorite Icecream Flavor',
      variable_type: 'choices',
      labels: %w(food dessert)
    }
  end

  def domain_params
    {
      name: 'flavors',
      folder: '',
      options: options_params,
      spout_version: 'x.x.x'
    }
  end

  def options_params
    [
      {
        display_name: 'Vanilla',
        value: '1'
      },
      {
        display_name: 'Chocolate',
        value: '2',
        description: '',
        missing: false
      },
      {
        display_name: 'Refused to answer',
        value: '-9',
        description: 'Participant refused to answer.',
        missing: true
      }
    ]
  end

  def form_params
    {
      name: 'market_survey',
      folder: 'folder',
      display_name: 'Market Survey',
      code_book: 'market-survey.pdf',
      spout_version: 'x.x.x'
    }
  end

  test 'should get index' do
    get :index, params: {
      auth_token: users(:editor).id_and_auth_token,
      version: '0.1.0',
      dataset: datasets(:public).to_param
    }, format: 'json'
    assert_response :success
  end

  test 'should get variable' do
    get :show, params: {
      id: variables(:one),
      auth_token: users(:editor).id_and_auth_token,
      version: '0.1.0',
      dataset: datasets(:public).to_param
    }, format: 'json'
    assert_response :success
  end

  test 'should not get variable with invalid id' do
    get :show, params: {
      id: '',
      auth_token: users(:editor).id_and_auth_token,
      version: '0.1.0',
      dataset: datasets(:public).to_param
    }, format: 'json'
    assert_response :unprocessable_entity
  end

  test 'should create variable' do
    assert_difference('Variable.count') do
      assert_difference('Domain.count') do
        assert_difference('Form.count') do
          assert_difference('DomainOption.count', 3) do
            post :create_or_update, params: {
              auth_token: users(:editor).id_and_auth_token,
              version: '0.1.0',
              dataset: datasets(:public).to_param,
              variable: variable_params,
              domain: domain_params,
              forms: [form_params]
            }, format: 'json'
          end
        end
      end
    end
    assert_not_nil assigns(:variable)
    assert_equal [], assigns(:variable).labels.sort
    assert_equal %w(dessert food), assigns(:variable).variable_labels.pluck(:name).sort
    assert_response :success
  end

  test 'should create variable form with invalid form name' do
    assert_difference('Form.count', 0) do
      post :create_or_update, params: {
        auth_token: users(:editor).id_and_auth_token,
        version: '0.1.0',
        dataset: datasets(:public).to_param,
        variable: variable_params,
        domain: domain_params,
        forms: [form_params.merge(name: '')]
      }, format: 'json'
    end
    assert_response :unprocessable_entity
  end
end

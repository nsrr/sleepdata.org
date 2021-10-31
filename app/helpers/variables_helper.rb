# frozen_string_literal: true

module VariablesHelper
  def calculation_pieces(variable)
    new_calculation = variable.calculation.to_s
    variables = variable.dataset.variables.where(dataset_version_id: variable.dataset_version_id)
    subcomponent_variables = variables.where(name: variable.calculation.to_s.split(/[^\w]/).uniq)
    version = if variable.dataset.dataset_version_id != variable.dataset_version_id
                variable.dataset_version.version
              end
    subcomponent_variables.each do |v|
      new_calculation.gsub!(
        /(^|\W)#{v.name}($|\W)/,
        "\\1" + link_to(v.name, dataset_variable_path(v.dataset, v, version: version)) + "\\2"
      )
    end
    new_calculation.html_safe
  end

  def calculation_helper(variable)
    content_tag(
      :span,
      content_tag(:u, variable.name) + " = " + calculation_pieces(variable),
      class: "variable-calculation"
    )
  end

  def description_with_linked_variables(variable)
    variable.description?.gsub(/\:(\w*?)\:/, "[\\1](#{dataset_path(@dataset)}/variables/\\1?v=#{variable.dataset_version.version})")
  end
end

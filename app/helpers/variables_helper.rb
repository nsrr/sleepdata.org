module VariablesHelper

  def calculation_pieces(variable)
    new_calculation = variable.calculation.to_s
    subcomponent_variables = variable.dataset.variables.where( name: variable.calculation.to_s.split(/[^\w]/).uniq )
    subcomponent_variables.each do |v|
      new_calculation.gsub!(/(^|\W)#{v.name}($|\W)/, '\1' + link_to(v.name, dataset_variable_path(v.dataset, v)) + '\2')
    end
    new_calculation.html_safe
  end

  def calculation_helper(variable)
    content_tag(
      :span,
      content_tag( :u, variable.name ) +
      " = " + calculation_pieces(variable)
    )
  end

end

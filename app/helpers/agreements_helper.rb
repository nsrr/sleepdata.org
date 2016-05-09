# frozen_string_literal: true

# Helps display status of agreements
module AgreementsHelper
  def status_helper_simple(agreement)
    content_tag(:span, agreement.status)
  end

  def status_helper(agreement)
    content_tag(
      :span, agreement.status,
      class: "label label-#{status_hash[agreement.status]}"
    )
  end

  def step_helper(agreement, step, selected_step)
    if step == selected_step
      'info'
    elsif step == 6
      'default'
    elsif agreement.step_valid?(step)
      'success'
    else
      'default'
    end
  end

  def step_helper_2(agreement, step)
    if step != 6 && agreement.step_valid?(step)
      'check agreement-step-completed'
    else
      'unchecked'
    end
  end

  def status_hash
    {
      'started' => 'warning',
      'submitted' => 'info',
      'approved' => 'success',
      'resubmit' => 'danger',
      'expired' => 'default',
      'closed' => 'danger'
    }
  end
end

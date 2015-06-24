module AgreementsHelper

  def status_helper(agreement)
    status_hash = { 'approved' => 'success',
                    'resubmit' => 'danger',
                    'submitted' => 'primary',
                    'expired' => 'default',
                    '' => 'warning'
                  }
    content_tag(
      :span, agreement.status.blank? ? 'started' : agreement.status,
      class: "label label-#{status_hash[agreement.status.to_s]}"
    )
  end

  def step_helper(agreement, step, selected_step)
    if step == selected_step
      'primary'
    elsif step == 6
      'warning'
    elsif agreement.step_valid?(step)
      'success'
    else
      'warning'
    end
  end

end

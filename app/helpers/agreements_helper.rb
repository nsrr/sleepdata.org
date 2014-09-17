module AgreementsHelper

  def status_helper(agreement)
    status_hash = { 'approved' => 'success',
                    'resubmit' => 'danger',
                    'submitted' => 'warning',
                    'expired' => 'default',
                    '' => 'default'
                  }
    content_tag(
      :span, agreement.status || 'started',
      class: "label label-#{status_hash[agreement.status.to_s]}"
    )
  end

  def step_helper(agreement, step, selected_step)

    if step == selected_step
      return 'primary'
    elsif step > selected_step
      return 'default'
    end

    if agreement.step_valid?(step)
      'success'
    else
      'warning'
    end

  end

end

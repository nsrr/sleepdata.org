module AgreementsHelper

  def status_helper(agreement)
    status_hash = { 'approved' => 'success',
                    'resubmit' => 'danger',
                    'submitted' => 'warning',
                    '' => 'default'
                  }
    content_tag(
      :span, agreement.status,
      class: "label label-#{status_hash[agreement.status.to_s]}"
    )
  end

end

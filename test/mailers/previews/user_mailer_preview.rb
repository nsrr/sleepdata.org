class UserMailerPreview < ActionMailer::Preview

  def forum_digest
    user = User.first
    UserMailer.forum_digest(user)
  end

  def post_replied
    post = Post.first
    user = User.first
    UserMailer.post_replied(post, user)
  end

  def reviewer_digest
    user = User.first
    UserMailer.reviewer_digest(user)
  end

  def daua_approved
    agreement = Agreement.first
    admin = User.first

    UserMailer.daua_approved(agreement, admin)
  end

  def dataset_access_requested
    dataset_user = DatasetUser.first
    editor = User.first

    UserMailer.dataset_access_requested(dataset_user, editor)
  end

  def dataset_access_approved
    dataset_user = DatasetUser.first
    editor = User.first

    UserMailer.dataset_access_approved(dataset_user, editor)
  end

  def daua_progress_notification
    agreement = Agreement.first
    admin = User.first

    UserMailer.daua_progress_notification(agreement, admin)
  end

  def daua_submitted
    agreement = Agreement.first
    admin = User.first
    UserMailer.daua_submitted(admin, agreement)
  end

  def notify_system_admin
    system_admin = User.current.first
    user = User.current.first
    UserMailer.notify_system_admin(system_admin, user)
  end

  def sent_back_for_resubmission
    agreement = Agreement.first
    admin = User.first
    UserMailer.sent_back_for_resubmission(agreement, admin)
  end

  def mentioned_in_comment
    user = User.first
    comment = Comment.first
    UserMailer.mentioned_in_comment(comment, user)
  end

  def mentioned_in_agreement_comment
    user = User.first
    agreement_event = AgreementEvent.where( event_type: 'commented' ).first
    UserMailer.mentioned_in_agreement_comment(agreement_event, user)
  end


end

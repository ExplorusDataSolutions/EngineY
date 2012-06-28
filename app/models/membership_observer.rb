class MembershipObserver < ActiveRecord::Observer

  def after_create(membership)
    if !(membership.user_id == membership.group.creator.id)
      if membership.group.private
        MembershipMailer.deliver_private_member_request(membership)
      else
        MembershipMailer.deliver_member_joined(membership)
      end
    end
  end
  
end

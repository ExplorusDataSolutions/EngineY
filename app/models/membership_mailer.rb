class MembershipMailer < ActionMailer::Base

  def init
    @network = Network.find(:first)
    @url = @network.url
    @network_name = @network.name
    @admin_email = @network.admin_email
  end
  
  def member_joined(membership)
    setup_email(membership)
    
    @subject = "#{@network_name} Your group #{@group_name} has a new member."
  end
  
  def private_member_request(membership)
    setup_email(membership)
    
    @subject = "#{@network_name} Your private group #{@group_name} has a new member request and requires your attention."
  end
    
  private
  
  def setup_email(membership)
    emails = membership.group.admins.collect { |p| p.email } 
    emails.push(membership.group.creator.email) unless !membership.group.creator
    @recipients  = emails.join(',')  
    @from        = "#{@admin_email}"
    @subject     = "[#{@network_name}]"
    @sent_on     = Time.now

    @content_type = "text/html"
    
    user = membership.user
    @user_name = user.name
    @user_id = user.id
    group = membership.group
    @group_name = group.name
    @group_id = group.id
  end

end

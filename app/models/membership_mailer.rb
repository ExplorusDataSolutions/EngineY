class MembershipMailer < ActionMailer::Base
 
  def member_joined(membership)
    setup_email(membership)

    @subject = "#{@network_name}. Your public group #{@group_name} has a new member."
  end
  
  def private_member_request(membership)
    setup_email(membership)
    
    @subject = "#{@network_name}. Your private group #{@group_name} has a new member request and requires your attention."
  end
    
  private
  
  def setup_email(membership)
    @network = Network.find(:first)
    @network_name = @network.name
    @admin_email = @network.admin_email
    
    # ugly...
    # for whatever reason membership.admins does not work as expected, the following gets the group_admins
    all_users = membership.group.all_users
    emails = []
    user_ids = membership.group.memberships.collect { |m| m.user_id if m.role == Role.group_admin }
    user_ids.each do |id|
      if id
        all_users.each do |user|
          if user.id == id
            emails.push(user.email)
          end
        end
      end
    end
      
    emails.push(membership.group.creator.email) unless !membership.group.creator
    emails.uniq!
    
    @recipients  = emails.join(',')  

    @from        = "#{@admin_email}"
    @subject     = "[#{@network_name}]"
    @sent_on     = Time.now

    @content_type = "text/html"
    
    user = membership.user
    @body[:user_name] = user.name
    @body[:user_id] = user.id
    group = membership.group
    @body[:group_name] = group.name
    @body[:group_id] = group.id
  end

end

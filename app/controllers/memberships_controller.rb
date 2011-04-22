#   Copyright 2009 Timothy Fisher
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.


=begin
  This class handles group memberships.
  A membership consists of a user, a group, and a role.
=end
class MembershipsController < ApplicationController
  
  
  def show
    @membership = Membership.find(params[:id]) 
    #debugger
    if @membership
      respond_to do |format|
        format.xml { render :xml => @membership } 
        format.json { render :json => @membership } 
      end
    else
      respond_to do |format|
        format.xml { render :status => :unprocessable_entity } 
        format.json { render :status => :unprocessable_entity } 
      end
    end
  end
  
  
  def find
    @membership = Membership.find_by_user_id_and_group_id(params[:user_id], params[:group_id])
    if @membership
      respond_to do |format|
        format.html
        format.xml { render :xml => @membership }  
        format.json { render :json => @membership } 
      end
    else
      respond_to do |format|
        format.html
        format.xml { render :xml => '', :status => :unprocessable_entity }  
        format.json { render :json => '', :status => :unprocessable_entity } 
      end
    end
  end
  
  
  # Add a user to a group
  def create
    group_id = params[:group_id]
    user = User.find(params[:user_id])
    group = Group.find_by_id(group_id)
    if user.is_admin || group.creator == current_user
      role = Role.find_by_rolename('group_admin')
    else
      role = Role.find_by_rolename('user')
    end
    
    is_authorized = false

    if group.private
      if user.is_admin || group.creator == current_user
        is_authorized = true
      end
    else
      is_authorized = true
    end   

    @membership = Membership.create({:group_id => params[:group_id], 
                                     :user_id => user.id,
                                     :role_id => role.id,
                                     :authorized => is_authorized})
    if @membership.save
      respond_to do |format|
        format.html { redirect_to group_path(group_id) }
        format.xml { render :xml => @membership, :status => :created } 
        format.json { render :json => @membership, :status => :created } 
      end
    else
      respond_to do |format|
        format.html { redirect_to group_path(group_id) }
        format.xml  { render :xml => @membership.errors, :status => :unprocessable_entity }
        format.json { render :json => @membership.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  
  # Changes a membership, typically used to change the role of a user, i.e.
  # to promote or demote a member from the group admin role.
  def update
    if params[:user_ids].is_a?(Array)
      params[:user_ids].each do |id| 
        task = params[:task]
        user = User.find(id)
        group_id = params[:group_id]

        if task == 'demote'
          permissions = Permission.find_by_user_id_and_group_id_and_role_id(id, group_id, Role.group_admin.id)
          permissions.destroy
        else
          Permission.create(:user_id => id, :group_id => group_id, :role_id => Role.group_admin.id) #unless user.roles.include?(Role.group_admin)
        end
      end
    end
    respond_to do |format|
      format.html { 
        flash[:notice] = 'Membership was successfully updated.'
       }
      format.xml  { head :ok }
      format.json { head :ok }
    end
  end
  
  def authorize
    if params[:user_ids].is_a?(Array)
      params[:user_ids].each do |id| 
        membership = Membership.find_by_user_id_and_group_id(id, params[:group_id])
        membership.authorized = true
        membership.save
      end
    end
  end
  
  # Remove a user from a group
  def destroy
    if params[:user_ids].is_a?(Array)
      params[:user_ids].each do |id| 
        @membership = Membership.find_by_user_id_and_group_id(id, params[:group_id])
        @membership.destroy       
      end
    end
    respond_to do |format|
      format.html { 
      }
      format.xml  { head :ok }
      format.json { head :ok } 
    end
  end
  
end

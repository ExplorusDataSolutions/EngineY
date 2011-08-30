class ApiKeysController < ApplicationController
  
  before_filter :login_from_cookie, :except => [:show]
  before_filter :login_required, :except => [:show]
 
 
  # Create or re-generate the API key
  def create
    current_user.enable_api!
    respond_to do |format|
      format.html { redirect_to edit_user_path(current_user) }
    end
  end
 
 
  # Delete the API key
  def destroy
    current_user.disable_api!
    respond_to do |format|
      format.html { redirect_to edit_user_path(current_user) }
    end
  end
  
  def show
    user = User.find_by_api_key(params[:id])
    if user
      render :nothing => true and return
    end
    render :nothing => true, :status => :forbidden and return
  end
 
end

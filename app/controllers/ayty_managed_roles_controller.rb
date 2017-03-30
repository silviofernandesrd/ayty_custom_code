##### AYTYCRM - Silvio Fernandes #####

class AytyManagedRolesController < ApplicationController
  layout 'admin'
  
  before_filter :require_admin
  before_filter :find_role, :only => [:edit, :update]
  
  def index
    respond_to do |format|
      format.html {
        @role_pages, @roles = paginate Role.sorted, :per_page => 25
        render :action => "index", :layout => false if request.xhr?
      }
      format.api {
        @roles = Role.givable.to_a
      }
    end
  end

  def edit
  end

  def update
    if @role.update_attributes(params[:role])
      flash[:notice] = l(:notice_successful_update)
      redirect_to ayty_managed_roles_path(:page => params[:page])
    else
      render :action => 'edit'
    end
  end

  private

  def find_role
    @role = Role.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end

end

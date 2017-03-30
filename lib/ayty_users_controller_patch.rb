##### AYTYCRM - Silvio Fernandes #####

UsersController.class_eval do

  before_filter :fill_ayty_selectable_users, :only => [:edit, :ayty_replicate_memberships]

  def fill_ayty_selectable_users
    # ARM - Ayty Replicate Membership
    @ayty_selectable_users = User.ayty_users
  end

  # ARM - Ayty Replicate Memberships
  def ayty_replicate_memberships
    # usuario que sera atualizado
    @user = User.find(params[:id])

    @user.ayty_replicate_memberships_by_user_id(params[:ayty_user_stunt_id])

    respond_to do |format|
      format.html { redirect_to :controller => 'users', :action => 'edit', :id => @user, :tab => 'memberships' }
      format.js
    end
  end


  def index_manager
    @ayty_users_manager = User.joins(:ayty_manager_users).order(:login).uniq
    @ayty_selectable_users = User.ayty_users

    respond_to do |format|
      format.html
    end
  end

  def index_managed
    @ayty_users_managed = User.joins(:ayty_managed_users).order(:login).uniq
    @ayty_selectable_users = User.ayty_users

    respond_to do |format|
      format.html
    end
  end

  def edit_manager
    @ayty_user_manager = User.find(params[:user_selected])
    @ayty_selected_users = @ayty_user_manager.managed_users
    @ayty_selectable_users = User.ayty_users

    respond_to do |format|
      format.html
    end
  end

  def edit_managed
    @ayty_user_managed = User.find(params[:user_selected])
    @ayty_selected_users = @ayty_user_managed.manager_users
    @ayty_selectable_users = User.ayty_users

    respond_to do |format|
      format.html
    end
  end

  def update_manager
    @ayty_user_manager = User.find(params[:id])

    respond_to do |format|
      if @ayty_user_manager.update(managed_user_params)
        @ayty_user_manager.ayty_manager_users.where(:author_id => nil).update_all(:author_id => User.current.id)
        flash[:notice] = l(:notice_successful_update)
      else
        flash[:warning] = l(:ayty_notice_unsuccessful_update)
      end

      @ayty_selectable_users = User.ayty_users
      @ayty_selected_users = @ayty_user_manager.managed_users

      format.html {
        render :action => "edit_manager", :id => @ayty_user_manager
      }
    end
  end

  def managed_user_params
    params.require(:user).permit(:managed_user_ids => [])
  end

  def update_managed
    @ayty_user_managed = User.find(params[:id])

    respond_to do |format|
      if @ayty_user_managed.update(manager_user_params)
        @ayty_user_managed.ayty_managed_users.where(:author_id => nil).update_all(:author_id => User.current.id)
        flash[:notice] = l(:notice_successful_update)
      else
        flash[:warning] = l(:ayty_notice_unsuccessful_update)
      end

      @ayty_selectable_users = User.ayty_users
      @ayty_selected_users = @ayty_user_managed.manager_users

      format.html {
        render :action => "edit_managed", :id => @ayty_user_managed
      }
    end
  end

  def manager_user_params
    params.require(:user).permit(:manager_user_ids => [])
  end

  def delete_all_manager
    @ayty_user_manager = User.find(params[:id])

    @ayty_user_manager.managed_users.delete_all

    respond_to do |format|
      format.html { redirect_to(:action => :index_manager) }
    end
  end

  def delete_all_managed
    @ayty_user_managed = User.find(params[:id])

    @ayty_user_managed.manager_users.delete_all

    respond_to do |format|
      format.html { redirect_to(:action => :index_managed) }
    end
  end
end
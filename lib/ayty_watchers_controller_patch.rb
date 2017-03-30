##### AYTYCRM - Silvio Fernandes #####

WatchersController.class_eval do

  def users_for_new_watcher

    # pega os roles do usuario
    managed_roles = User.current.ayty_managed_roles(@project)

    scope = nil
    if params[:q].blank? && @project.present?
      # filtra por ayay_managed_roles
      scope = @project.users.joins(:members => :roles).ayty_filter_managed_roles(:managed_roles => managed_roles)
    else
      # filtra por ayay_managed_roles
      scope = User.joins(:members => :roles).ayty_filter_managed_roles(:managed_roles => managed_roles).all.limit(100)
    end

    users = scope.active.visible.sorted.like(params[:q]).to_a

    if @watched
      users -= @watched.watcher_users
    end

    # acrescentado uniq
    users.uniq
  end

end
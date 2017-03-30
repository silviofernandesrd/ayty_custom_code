##### AYTYCRM - Silvio Fernandes #####

ApplicationController.class_eval do

  # override
  def authorize(ctrl = params[:controller], action = params[:action], global = false)

    allowed = User.current.allowed_to?({:controller => ctrl, :action => action}, @project || @projects, :global => global)

    # se existir apontamento, valida regra dos ultimos 10 minutos
    allowed = @time_entry.user == User.current && @time_entry.created_on >= DateTime.current().ago(600) if @time_entry && !allowed

    # se existir comentario, valida regra dos ultimos 10 minutos
    allowed = @journal.user == User.current && @journal.created_on >= DateTime.current().ago(600) if @journal && !allowed

    if allowed
      true
    else
      if @project && @project.archived?
        render_403 :message => :notice_not_authorized_archived_project
      else
        deny_access
      end
    end
  end

  def require_ayty_user
    return unless require_login
    unless User.current.ayty_is_user_ayty?
      render_403
      return false
    end
    true
  end

end
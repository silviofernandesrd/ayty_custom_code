##### AYTYCRM - Silvio Fernandes #####

ContextMenusController.class_eval do

  #OVERRIDE
  def issues
    if (@issues.size == 1)
      @issue = @issues.first
    end
    @issue_ids = @issues.map(&:id).sort

    @allowed_statuses = @issues.map(&:new_statuses_allowed_to).reduce(:&)

    @can = {:edit => User.current.allowed_to?(:edit_issues, @projects),
            :log_time => (@project && User.current.allowed_to?(:log_time, @project)),
            :copy => User.current.allowed_to?(:copy_issues, @projects) && Issue.allowed_target_projects.any?,
            :delete => User.current.allowed_to?(:delete_issues, @projects)
    }
    if @project
      if @issue

        #@assignables = @issue.assignable_users
        @assignables = @issue.ayty_assignable_users

      else

        #@assignables = @project.assignable_users
        @assignables = @project.ayty_assignable_users

      end
      @trackers = @project.trackers
    else

      #when multiple projects, we only keep the intersection of each set
      #@assignables = @projects.map(&:assignable_users).reduce(:&)
      @assignables = @projects.map(&:ayty_assignable_users).reduce(:&)

      @trackers = @projects.map(&:trackers).reduce(:&)
    end
    @versions = @projects.map {|p| p.shared_versions.open}.reduce(:&)

    @priorities = IssuePriority.active.reverse
    @back = back_url

    @options_by_custom_field = {}
    if @can[:edit]
      custom_fields = @issues.map(&:editable_custom_fields).reduce(:&).reject(&:multiple?)
      custom_fields.each do |field|
        values = field.possible_values_options(@projects)
        if values.present?
          @options_by_custom_field[field] = values
        end
      end
    end

    @safe_attributes = @issues.map(&:safe_attribute_names).reduce(:&)
    render :layout => false
  end

end
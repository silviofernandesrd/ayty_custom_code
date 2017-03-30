##### AYTYCRM - Silvio Fernandes #####

IssuesController.class_eval do

  before_filter :authorize, :except => [:index, :new, :create, :ayty_template_notes]

  # OVERRIDE
  # Bulk edit/copy a set of issues
  def bulk_edit
    @issues.sort!
    @copy = params[:copy].present?
    @notes = params[:notes]

    if @copy
      unless User.current.allowed_to?(:copy_issues, @projects)
        raise ::Unauthorized
      end
    end

    @allowed_projects = Issue.allowed_target_projects
    if params[:issue]
      @target_project = @allowed_projects.detect {|p| p.id.to_s == params[:issue][:project_id].to_s}
      if @target_project
        target_projects = [@target_project]
      end
    end
    target_projects ||= @projects

    if @copy
      # Copied issues will get their default statuses
      @available_statuses = []
    else
      @available_statuses = @issues.map(&:new_statuses_allowed_to).reduce(:&)
    end
    @custom_fields = @issues.map{|i|i.editable_custom_fields}.reduce(:&)

    ##### AYTYCRM - Silvio Fernandes #####
    #@assignables = target_projects.map(&:assignable_users).reduce(:&)
    @assignables = target_projects.map(&:ayty_assignable_users).reduce(:&)

    @trackers = target_projects.map(&:trackers).reduce(:&)
    @versions = target_projects.map {|p| p.shared_versions.open}.reduce(:&)
    @categories = target_projects.map {|p| p.issue_categories}.reduce(:&)
    if @copy
      @attachments_present = @issues.detect {|i| i.attachments.any?}.present?
      @subtasks_present = @issues.detect {|i| !i.leaf?}.present?
    end

    @safe_attributes = @issues.map(&:safe_attribute_names).reduce(:&)

    @issue_params = params[:issue] || {}
    @issue_params[:custom_field_values] ||= {}
  end

  # Metodo para inserir Templates nas Notas do Redmine
  def ayty_template_notes
    ayty_template_note = AytyTemplateNote.find(params[:ayty_template_note_id]) unless params[:ayty_template_note_id].blank?
    ""
    @ayty_template_note_text = ayty_template_note.nil? ? "" : ayty_template_note.template

    respond_to do |format|
      format.js
    end
  end

end
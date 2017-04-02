class AytyManagementsController < ApplicationController
  def has_pending
    issue = Issue.find(params[:issue_id])
    @pendings = issue.show_pending
    respond_to do |format|
      format.js
    end
  end

  def has_checklist
    issue = Issue.find(params[:issue_id])
    @pendings = issue.show_checklist
    respond_to do |format|
      format.js
    end
  end
end

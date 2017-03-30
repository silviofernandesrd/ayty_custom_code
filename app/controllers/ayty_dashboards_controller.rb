class AytyDashboardsController < ApplicationController

  ##### AYTYCRM - Silvio Fernandes #####
  # Controller para Ayty Dashboard

  before_filter :require_ayty_user

  before_filter :validate_permission_create, :only => :create
  before_filter :validate_permission_update, :only => [:update, :sort]
  before_filter :validate_permission_delete, :only => :destroy

  def index
    @users = User.ayty_users

    @ayty_dashboard = AytyDashboard.new

    respond_to do |format|
      unless params[:popup].nil?
        format.html {render :layout => false }
      else
        format.html {}
      end
    end
  end

  def show
    @ayty_dashboard = AytyDashboard.find(params[:id])

    ayty_users = @ayty_dashboard.ayty_dashboards_users

    @ayty_dashboards_users = []

    ayty_users.each do |u|
      issues, issues_total = AytyDashboard.get_issues(u.user_id)
      @ayty_dashboards_users << {
        :user => u.user,
        :issue_play => u.user.time_trackers.where(:paused => false).first,
        :issues => issues,
        :issues_total => issues_total
      }
    end

    @users = User.ayty_users.where.not(:id => ayty_users.map(&:user_id))

    @popup = params[:popup]
    respond_to do |format|
      if @popup.present?
        format.html {render :layout => false }
      else
        format.html {}
      end
    end
  end

  def create
    if params[:add] == "dashboard"
      @ayty_dashboard = AytyDashboard.new(:name => (params[:ayty_dashboard][:name] || rand(32**8).to_s(32)))
      if @ayty_dashboard.save
        params[:ayty_dashboard][:blocks].each do |key, value|
          AytyDashboardsUser.new({:ayty_dashboard_id => @ayty_dashboard.id, :user_id => key, :position => value[:position]}).save
        end if params[:ayty_dashboard][:blocks]
        render :js => "window.location = '#{ayty_dashboard_path(@ayty_dashboard)}'"
      end
    else
      if params[:add] == "block"
        @ayty_dashboard = AytyDashboard.new
        @user = User.find(params[:ayty_dashboard][:user_id])
        @issue_play = @user.time_trackers.where(:paused => false).first
        @issues, @issues_total = AytyDashboard.get_issues(@user.id)
        if params[:ayty_dashboard][:blocks]
          @users = User.ayty_users.where.not(:id => [@user.id] + params[:ayty_dashboard][:blocks].map(&:first))
        else
          @users = User.ayty_users.where.not(:id => @user.id)
        end
      end
    end
  end

  def update
    @user = User.find(params[:ayty_dashboard][:user_id])
    @issue_play = @user.time_trackers.where(:paused => false).first
    @issues, @issues_total = AytyDashboard.get_issues(@user.id)
    @ayty_dashboard = AytyDashboard.find(params[:id])
    AytyDashboardsUser.new({:ayty_dashboard_id => @ayty_dashboard.id, :user_id => @user.id, :position => @ayty_dashboard.next_position}).save
    @users = User.ayty_users.where.not(:id => [@user.id] + @ayty_dashboard.ayty_dashboards_users.map(&:user_id))

    respond_to do |format|
      format.html { }
      format.js
    end
  end

  def sort
    params[:order].each do |key,value|
      AytyDashboardsUser.find_by_ayty_dashboard_id_and_user_id(value[:ayty_dashboard_id], value[:user_id]).update_attribute(:position, value[:position])
    end
    render :nothing => true
  end

  def destroy
    if params[:del] == "block"
      @ayty_dashboard = AytyDashboard.find(params[:id])

      @user = User.find(params[:ayty_dashboard][:user_id])

      if @ayty_dashboard && @user
        AytyDashboardsUser.find_by_ayty_dashboard_id_and_user_id(@ayty_dashboard, @user).delete
        @users = User.ayty_users.where.not(:id => @ayty_dashboard.ayty_dashboards_users.map(&:user_id))
      end
      respond_to do |format|
        format.html { }
        format.js
      end
    elsif params[:del] == "dashboard"
      @ayty_dashboard = AytyDashboard.find(params[:id])

      if @ayty_dashboard.destroy
        render js: "window.location = '#{ayty_dashboards_path}'"
      end
    end
  end

  def validate_permission_create
    unless User.current.can_create_ayty_dashboard?
      @render_403 = true
      render :create, :status => 403
      return false
    end
    true
  end

  def validate_permission_update
    unless User.current.can_update_ayty_dashboard?
      @render_403 = true
      render :update, :status => 403
      return false
    end
    true
  end

  def validate_permission_delete
    if params[:del] == "block"
      unless User.current.can_update_ayty_dashboard?
        @render_403 = true
        render :update, :status => 403
        return false
      end
    elsif params[:del] == "dashboard"
      unless User.current.can_delete_ayty_dashboard?
        @render_403 = true
        render :destroy, :status => 403
        return false
      end
    end
    true
  end
end

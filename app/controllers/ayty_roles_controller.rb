##### AYTYCRM - Silvio Fernandes #####

class AytyRolesController < ApplicationController
  layout 'admin'
  
  before_filter :require_admin
  
  def index
    @ayty_roles = AytyRole.order(:name).all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @ayty_roles }
    end
  end

  def show
    @ayty_role = AytyRole.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @ayty_role }
    end
  end

  def new
    @ayty_role = AytyRole.new
    
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @ayty_role }
    end
  end

  def edit
    @ayty_role = AytyRole.find(params[:id])
  end

  def create
    @ayty_role = AytyRole.new(params[:ayty_role])

    respond_to do |format|
      if @ayty_role.save
        flash[:notice] = l(:notice_successful_create)
        format.html { redirect_to(ayty_roles_path) }
        format.xml  { render :xml => @ayty_role, :status => :created, :location => @ayty_role }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @ayty_role.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    @ayty_role = AytyRole.find(params[:id])

    respond_to do |format|
      if @ayty_role.update_attributes(params[:ayty_role])
        flash[:notice] = l(:notice_successful_update)
        format.html { redirect_to(ayty_roles_path) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @ayty_role.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @ayty_role = AytyRole.find(params[:id])
    @ayty_role.destroy

    respond_to do |format|
      format.html { redirect_to(ayty_roles_url) }
      format.xml  { head :ok }
    end
  end
end

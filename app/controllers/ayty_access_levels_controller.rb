##### AYTYCRM - Silvio Fernandes #####

class AytyAccessLevelsController < ApplicationController
  layout 'admin'

  before_filter :require_admin
  
  def index
    @ayty_access_levels = AytyAccessLevel.all
  end

  def new
    @ayty_access_level = AytyAccessLevel.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @ayty_access_level }
    end
  end

  def edit
    @ayty_access_level = AytyAccessLevel.find(params[:id])
  end

  def create
    @ayty_access_level = AytyAccessLevel.new(params[:ayty_access_level])

    respond_to do |format|
      if @ayty_access_level.save
        flash[:notice] = 'Ayty Access Level was successfully created.'
        format.html { redirect_to(:controller => 'ayty_access_levels', :action => 'index') }
        format.xml  { render :xml => @ayty_access_level, :status => :created, :location => @ayty_access_level }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @ayty_access_level.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    @ayty_access_level = AytyAccessLevel.find(params[:id])

    respond_to do |format|
      if @ayty_access_level.update_attributes(params[:ayty_access_level])
        flash[:notice] = 'Ayty Access Level was successfully updated.'
        format.html { redirect_to(:controller => 'ayty_access_levels', :action => 'index') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @ayty_access_level.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @ayty_access_level = AytyAccessLevel.find(params[:id])
    @ayty_access_level.destroy

    respond_to do |format|
      format.html { redirect_to(:controller => 'ayty_access_levels', :action => 'index') }
      format.xml  { head :ok }
    end
  end
end

##### AYTYCRM - Silvio Fernandes #####

class AytyTimeEntryTypesController < ApplicationController
  layout 'admin'
  
  before_filter :require_admin
  before_filter :find_ayty_time_entry_type, :only => [:edit, :update, :destroy]
  
  def index
    respond_to do |format|
      format.html {
        @ayty_time_entry_types_pages, @ayty_time_entry_types = paginate AytyTimeEntryType.sorted, :per_page => 25
        render :action => "index", :layout => false if request.xhr?
      }
    end
  end

  def new
    @ayty_time_entry_type = AytyTimeEntryType.new
  end

  def create
    @ayty_time_entry_type = AytyTimeEntryType.new(ayty_time_entry_type_params)
    if @ayty_time_entry_type.save
      flash[:notice] = l(:notice_successful_create)
      redirect_to ayty_time_entry_types_path
      return
    end
    render :action => 'new'
  end

  def edit
  end

  def update
    if @ayty_time_entry_type.update_attributes(ayty_time_entry_type_params)
      flash[:notice] = l(:notice_successful_update)
      redirect_to ayty_time_entry_types_path(:page => params[:page])
    else
      render :action => 'edit'
    end
  end

  def ayty_time_entry_type_params
    params.require(:ayty_time_entry_type).permit(:name, :active, :position, :code, :client, :move_to)
  end

  def destroy

    @ayty_time_entry_type.destroy

    redirect_to ayty_time_entry_types_path
  end

  private

  def find_ayty_time_entry_type
    @ayty_time_entry_type = AytyTimeEntryType.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end

end

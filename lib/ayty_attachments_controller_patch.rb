##### AYTYCRM - Silvio Fernandes #####

AttachmentsController.class_eval do

  def upload
    # Make sure that API users get used to set this content type
    # as it won't trigger Rails' automatic parsing of the request body for parameters
    unless request.content_type == 'application/octet-stream'
      render :nothing => true, :status => 406
      return
    end

    @attachment = Attachment.new(:file => request.raw_post)
    @attachment.author = User.current
    @attachment.filename = params[:filename].presence || Redmine::Utils.random_hex(16)
    @attachment.content_type = params[:content_type].presence

    ##### AYTYCRM - Silvio Fernandes #####
    @attachment.ayty_access_level_id = params[:ayty_access_level_id].presence

    saved = @attachment.save

    respond_to do |format|
      format.js
      format.api {
        if saved
          render :action => 'upload', :status => :created
        else
          render_validation_errors(@attachment)
        end
      }
    end
  end
end
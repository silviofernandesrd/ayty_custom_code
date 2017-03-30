##### AYTYCRM - Silvio Fernandes #####

JournalsController.class_eval do

  # Metodo para alternar o comentario entre oculto e visivel
  def toggle_journal_ayty_hidden
    @ayty_journal = Journal.find(params[:journal_id])
    if @ayty_journal
      @ayty_journal.ayty_hidden = @ayty_journal.ayty_hidden ? false : true
    end
    if @ayty_journal.save
      respond_to do |format|
        format.js { render 'toggle_journal_ayty_hidden.js.erb' }
      end
    end
  end

  def toggle_journal_ayty_marked
    @ayty_journal = Journal.find(params[:journal_id])
    if @ayty_journal
      @ayty_journal.ayty_marked = @ayty_journal.ayty_marked? ? false : true
    end
    if @ayty_journal.save
      respond_to do |format|
        format.js { render 'toggle_journal_ayty_marked.js.erb' }
      end
    end
  end

end
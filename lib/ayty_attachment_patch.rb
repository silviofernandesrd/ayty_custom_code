##### AYTYCRM - Silvio Fernandes #####
require_dependency 'attachment'

module AytyAttachmentPatch
  extend ActiveSupport::Concern

  included do
    class_eval do
      belongs_to :ayty_access_level, :foreign_key => :ayty_access_level_id
    end
  end

  # metodo que retorna o nivel de acesso mais baixo caso nenhum valor esteja associado
  def ayty_access_level
    super || AytyAccessLevel.order("level ASC").first
  end

end

Attachment.send :include, AytyAttachmentPatch

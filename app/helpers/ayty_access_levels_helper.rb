##### AYTYCRM - Silvio Fernandes #####
module AytyAccessLevelsHelper

  # Metodo que traz o nome do nivel de acesso e não mostra para o cliente
  def ayty_get_access_level_name(user=User.current, ayty_access_level=nil)
    if user && ayty_access_level
      if user.ayty_access_level
        if user.ayty_access_level.ayty_access
          "(#{ayty_access_level.name})"
        end
      end
    end
  end

  # Metodo que faz verificação para saber se o usuario possui acesso ao conteudo
  def ayty_user_can_view_content?(user=User.current, ayty_access_level=nil)
    if user && ayty_access_level
      if user.ayty_access_level
        ayty_access_level.level <= user.ayty_access_level.level
      else
        false
      end
    else
      false
    end
  end

  # Retorna Array com Niveis de Acesso para um Select
  def ayty_access_level_options_for_select(user=User.current, option_selected = nil)
    ayty_options = AytyAccessLevel.order("level DESC").all.collect { |e| [e.name, e.id] }
    ayty_option_selected = option_selected.nil? ? (user.ayty_is_user_ayty? ? user.ayty_access_level_id : ayty_options.last if ayty_options) : option_selected
    options_for_select(ayty_options, ayty_option_selected)
  end

end

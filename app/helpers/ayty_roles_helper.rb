##### AYTYCRM - Silvio Fernandes #####
module AytyRolesHelper

  # Retorna Array com Cargos Ayty para um Select
  def ayty_roles_options_for_select
    AytyRole.order(:name).all.collect { |e| [e.name, e.id] }
  end

end

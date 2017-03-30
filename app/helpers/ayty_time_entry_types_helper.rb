##### AYTYCRM - Silvio Fernandes #####
module AytyTimeEntryTypesHelper

  # metodo para retornar os Tipos de Apontamento
  def ayty_time_entry_type_options_for_select(time_entry=nil, issue=nil)

    if time_entry || issue
      issue_valid = time_entry.nil? ? issue : time_entry.issue
      if issue_valid
        solution_type = issue_valid.ayty_get_value_by_custom_field_name('Tipo de Solução', '')
        if issue_valid.qt_client_homologation_repproval.to_i > 0 || issue_valid.status_id == 23
          ayty_code_time_entry_type = "EXTERNO"
        else
          if  issue_valid.qt_reproof_internal.to_i > 0 ||
              issue_valid.qt_reproof_external.to_i > 0 ||
              issue_valid.qt_business_homologation_repproval.to_i > 0 ||
              issue_valid.qt_test_repproval.to_i > 0
            ayty_code_time_entry_type = "INTERNO"
          else
            if solution_type.to_s == "Problema Ayty"
              ayty_code_time_entry_type = "BUG"
            else
              if ["Tarefa","Melhoria","Problema Externo","Proposta Comercial"].include?(solution_type.to_s)
                ayty_code_time_entry_type = "NORMAL"
              end
            end
          end
        end
      end
    end

    collection = []
    collection << [[ "--- #{l(:actionview_instancetag_blank_option)} ---", '' ]]
    collection << (AytyTimeEntryType.sorted.collect { |e|
      if ayty_code_time_entry_type
        style = (e.code == ayty_code_time_entry_type) ? 'background: #EEE; color: red;' : "background: #FFF; color: #000;"
        [e.name, e.id, {:style => style}]
      else
        [e.name, e.id]
      end
    })

    selected_item = time_entry.ayty_time_entry_type_id if time_entry

    selected_item = AytyTimeEntryType.where(:code => ayty_code_time_entry_type).first.id if ayty_code_time_entry_type

    options_for_select(collection.reduce(:concat), selected_item)
  end

end

##### AYTYCRM - Silvio Fernandes #####
module AytyIssuePrioritiesHelper

  # Metodo para retornar um color para a linha da tabela de prioridade de acordo com as regras abaixo
  # caso o ticket seja o mesmo que esta em play coloca em azul
  # caso o ticket seja uma solicitacao do cliente de Problema sem Solucao aplicada ou
  # quando a Solucao for Problema Ayty coloca em vermelho
  # caso o status do ticket for Ayty - Ag Deploy - Pré-Homolo coloca em verde claro
  # caso o status do ticket for Ayty - Reprovado no Teste coloca em laranja
  # caso o status do ticket for Ayty - Homolog Técnica ou Ayty - Na Fila - Retorno HouT coloca em roxo
  # caso nao comtemple nenhuma regra acima retornar string em branco
  def ayty_background_issue_priority_for_style(issue, issue_play)
    if issue.id.to_s == issue_play.to_s
      return "background: #5CACEE"
    end

    solution_type = issue.ayty_get_value_by_custom_field_name("Tipo de Solução")

    if solution_type == "Problema Ayty"
      return "background: #FA5050"
    else
      request_type = issue.ayty_get_value_by_custom_field_name("Tipo de Solicitação")
      if request_type == "Problema" && solution_type == ""
        return "background: #FA5050"
      end
    end

    case issue.status_id
      when 12
        return "background: #C8FFC8"
      when 22
        return "background: #FF9664"
      when 24,33
        return "background: #C864C8"
    end

    return ""
  end

  # Acrescentado metodo para retornar o color para a linha da tabela de responsabilidade
  # fazendo que fique de outra cor quando o ticket for de acordo com certo status
  # Como esse metodo utiliza id fixo, favor revisar depois
  def ayty_background_list_responsible_for_style(issue, issue_id_play)
    if issue.id.to_s == issue_id_play.to_s
      return "background: #5CACEE"
    end
    status_id = issue.status_id.to_i
    return  case status_id
              when 8,31
                "background: #A0A0A0"
              when 9,11
                "background: #FF9664"
              when 25,14
                "background: #00C864"
              when 22,23
                "background: #FA5050"
              when 34,13
                "background: #C8FFC8"
              when 32
                "background: #C878C8"
              when 15,16,17
                "background: #508250"
            else
              ""
            end
  end

  # Acrescentado metodo para retornar um color para a data informada, respeitando o padrao da SLA
  # Regra: Atrasado em vermelho; No dia em Amarelo (Laranja), Proximos 3 dias em Azul
  def ayty_background_color_sla_for_date(date)
    if date
      date_parsed = Date.parse(date.strftime("%Y-%m-%d"))
      date_now = Date.current
      days = (date_now - date_parsed).round

      case
        when days < 0 && days >= -3
          return "background: #5CACEE"
        when days == 0
          return "background: #FF9664"
        when days > 0
          return "background: #FA5050"
      end
    end
  end

  # metodo para retornar cor para colunas de tempo restante
  # regra: ticket na fila do usuario como responsavel que foi dado play nas ultimas 36 horas
  # caso o campo tempo restante seja nulo ou tenha sido alterado entre 4 a 8 horas retorna amarelo
  # caso for maior que isso retornar vermelho
  def ayty_background_color_for_remainder_time(issue, user, user_responsible, last_update, time_trackers)
    if user == user_responsible
      if time_trackers.any?
        time_tracker_detected = time_trackers.detect { |t| t.issue_id == issue.id }
        if time_tracker_detected
          if time_tracker_detected.time_spent > 0.0
            last_update_time = last_update.to_time if last_update
            last_update_hour = ((Time.now.to_time - last_update_time)/3600) if last_update_time
            if (4..8).include?(last_update_hour) or last_update_time.nil?
              return "background: #FCFD8D"
            else
              if last_update_hour > 8
                return "background: #FF9664"
              end
            end
          end
        end
      end
    end
  end

  # Retornar quantidade tempo que usuario esta em play em um ticket
  def ayty_get_time_spent_user_by_issue(issue, time_trackers)
    if time_trackers.any?
      time_tracker_detected = time_trackers.detect { |t| t.issue_id == issue.id }
      if time_tracker_detected
        return time_tracker_detected.time_spent_to_s
      end
    end
  end


end

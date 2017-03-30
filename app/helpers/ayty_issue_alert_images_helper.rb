##### AYTYCRM - Silvio Fernandes #####
module AytyIssueAlertImagesHelper

  # Metodo para retornar uma imagem de acordo com algumas regras
  def ayty_get_alerts_by_issue(issue, view_context=nil, div_base_class = nil)
    alerts = AytyIssueAlertImage.check_validates(issue)
    if alerts
      images_alert = Array.new
      alerts.each {|a|
        title = a.title ? parse_title(issue, a.title) : ""
        if view_context
          images_alert << view_context.image_tag("#{a.path}#{a.filename}", :plugin => 'ayty_custom_code', :class => :ayty_issue_alert_image, :title => title)
        else
          images_alert << image_tag("#{a.path}#{a.filename}", :plugin => 'ayty_custom_code', :class => :ayty_issue_alert_image, :title => title)
        end
      }
      if images_alert.any?
        div_class = div_base_class.nil? ? "" : div_base_class
        content_tag :div, :class => div_class, :onmouseover => "$('#ayty_issue_alert_div_popup_#{issue.id}').toggle()", :onmouseout => "$('#ayty_issue_alert_div_popup_#{issue.id}').toggle()" do

          ayty_html = images_alert.first if images_alert.first

          ayty_html += content_tag :div, :class => "ayty_issue_alert_div_popup", :id => "ayty_issue_alert_div_popup_#{issue.id}" do images_alert.join('').html_safe end

          ayty_html
        end
      end
    end
  end

  private

  def parse_title(issue, title)
    title_parsed = ""
    title.split("@").each{|i|
      field_issue = i.split("$").first.strip if i.split("$").any?
      unless issue[field_issue].nil?
        if issue[field_issue].is_a?(Time)
          title_parsed += format_time(issue[field_issue])
        else
          title_parsed += issue[field_issue].to_s
        end
      end
      title_parsed += i.sub(field_issue + "$","")
    }
    return title_parsed
  end

end

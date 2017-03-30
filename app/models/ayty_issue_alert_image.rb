##### AYTYCRM - Silvio Fernandes #####
# Issue Alert Images
class AytyIssueAlertImage < ActiveRecord::Base

  scope :sorted, lambda { order(:priority_show) }

  scope :active, lambda { where(:active => true) }

  def self.check_validates(issue)
    checklist = self.active.sorted.all
    if checklist
      return checklist.select { |c| validate_issue(issue, c) }
    end
  end

  private

  def self.validate_issue(issue, ayty_issue_alert_image)
    if issue && ayty_issue_alert_image
      if ayty_issue_alert_image.condition_sign.to_s == "="
        if issue["#{ayty_issue_alert_image.condition_field}"].to_s == ayty_issue_alert_image.condition_expected_value.to_s
          return true
        end
      end
      if ayty_issue_alert_image.condition_sign.to_s == "is not"
        if ayty_issue_alert_image.condition_expected_value.to_s == "null"
          return true unless issue["#{ayty_issue_alert_image.condition_field}"].nil?
        end
      end
    end
    false
  end
end

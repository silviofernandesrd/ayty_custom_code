##### AYTYCRM - Silvio Fernandes #####
class AddIssuesAytyColumns < ActiveRecord::Migration

  def self.up
    add_column :issues, :qt_reproof_internal, :integer
    add_column :issues, :qt_reproof_external, :integer
    add_column :issues, :qt_technical_homologation_repproval, :integer
    add_column :issues, :qt_business_homologation_repproval, :integer
    add_column :issues, :qt_test_repproval, :integer
    add_column :issues, :qt_client_homologation_repproval, :integer
    add_column :issues, :dt_start_desenv, :datetime
    add_column :issues, :dt_finish_desenv, :datetime
    add_column :issues, :dt_start_wait_test, :datetime
    add_column :issues, :dt_start_test, :datetime
    add_column :issues, :dt_finish_test, :datetime
    add_column :issues, :dt_start_homologation_tech, :datetime
    add_column :issues, :dt_finish_homologation_tech, :datetime
    add_column :issues, :dt_finish_homologation_tech_last, :datetime
    add_column :issues, :dt_start_aneg, :datetime
    add_column :issues, :dt_finish_aneg, :datetime
    add_column :issues, :dt_finish_aneg_last, :datetime
    add_column :issues, :dt_delivery_client, :datetime
    add_column :issues, :dt_delivery_client_last, :datetime
    add_column :issues, :dt_finish_desenv_transitional, :datetime
    add_column :issues, :dt_client_return, :datetime
    add_column :issues, :dt_client_return_last, :datetime
    add_column :issues, :dt_queue_enter, :datetime
    add_column :issues, :was_waiting_information_desenv, :boolean
    add_column :issues, :was_sent_techical_homologacion, :boolean
    add_column :issues, :was_sent_business_homologacion, :boolean
    add_column :issues, :was_client_delivery_delayed, :boolean
    add_column :issues, :was_tested, :boolean
    add_column :issues, :was_client_delivery_disapproved, :boolean
    add_column :issues, :was_aneg_delivery_delayed, :boolean
    add_column :issues, :was_delivery_delayed_client_after_disapproved, :boolean
  end

  def self.down
    remove_column :issues, :qt_reproof_internal
    remove_column :issues, :qt_reproof_external
    remove_column :issues, :qt_technical_homologation_repproval
    remove_column :issues, :qt_business_homologation_repproval
    remove_column :issues, :qt_test_repproval
    remove_column :issues, :qt_client_homologation_repproval
    remove_column :issues, :dt_start_desenv
    remove_column :issues, :dt_finish_desenv
    remove_column :issues, :dt_start_wait_test
    remove_column :issues, :dt_start_test
    remove_column :issues, :dt_finish_test
    remove_column :issues, :dt_start_homologation_tech
    remove_column :issues, :dt_finish_homologation_tech
    remove_column :issues, :dt_finish_homologation_tech_last
    remove_column :issues, :dt_start_aneg
    remove_column :issues, :dt_finish_aneg
    remove_column :issues, :dt_finish_aneg_last
    remove_column :issues, :dt_delivery_client
    remove_column :issues, :dt_delivery_client_last
    remove_column :issues, :dt_finish_desenv_transitional
    remove_column :issues, :dt_client_return
    remove_column :issues, :dt_client_return_last
    remove_column :issues, :dt_queue_enter
    remove_column :issues, :was_waiting_information_desenv
    remove_column :issues, :was_sent_techical_homologacion
    remove_column :issues, :was_sent_business_homologacion
    remove_column :issues, :was_client_delivery_delayed
    remove_column :issues, :was_tested
    remove_column :issues, :was_client_delivery_disapproved
    remove_column :issues, :was_aneg_delivery_delayed
    remove_column :issues, :was_delivery_delayed_client_after_disapproved
  end

end

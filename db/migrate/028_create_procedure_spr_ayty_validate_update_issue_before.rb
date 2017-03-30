# select para teste no postgresql
# select * from spr_ayty_validate_update_issue_before(
# null,null,null,null,null,null,null,null,null,null,null,null,null,null,'',
# '','','','','','', '','','','','','','','','','','','','','','','','','',
# '',null,null,'','','',null,null,'');
class CreateProcedureSprAytyValidateUpdateIssueBefore < ActiveRecord::Migration
  def self.up
    sql = case ActiveRecord::Base.connection_config[:adapter]
          when 'postgresql'
            '
            CREATE FUNCTION spr_ayty_validate_update_issue_before(
              issue_id INT,
              assigned_to_id_old INT,
              assigned_to_ayty_role_id_old INT,
              assigned_to_id INT,
              assigned_to_ayty_role_id INT,
              status_id_old INT,
              status_id INT,
              assigned_to_bd_id INT,
              assigned_to_net_id INT,
              assigned_to_test_id INT,
              assigned_to_areq_id INT,
              assigned_to_aneg_id INT,
              assigned_to_inf_id INT,
              fixed_version_id INT,
              due_date varchar(255),
              cf_request_type varchar(255),
              cf_solution_type varchar(255),
              cf_estimation_bd_old varchar(255),
              cf_estimation_bd varchar(255),
              cf_estimation_sys_old varchar(255),
              cf_estimation_sys varchar(255),
              cf_estimation_sys_col_old varchar(255),
              cf_estimation_sys_col varchar(255),
              cf_estimation_inf_old varchar(255),
              cf_estimation_inf varchar(255),
              cf_remainder_time_bd_old varchar(255),
              cf_remainder_time_bd varchar(255),
              cf_remainder_time_sys_old varchar(255),
              cf_remainder_time_sys varchar(255),
              cf_remainder_time_sys_col_old varchar(255),
              cf_remainder_time_sys_col varchar(255),
              cf_remainder_time_inf_old varchar(255),
              cf_remainder_time_inf varchar(255),
              cf_quality_ticket_to_reach_areq varchar(255),
              cf_quality_ticket_to_reach_des varchar(255),
              cf_release_general_internal varchar(255),
              cf_release_col_internal varchar(255),
              cf_status_post_delivery varchar(255),
              cf_instructions_to_deploy varchar(255),
              notes varchar(255),
              current_user_id INT,
              current_user_ayty_role_id INT,
              time_entry_hours varchar(255),
              time_entry_spent_on varchar(255),
              time_entry_comments varchar(255),
              time_entry_activity_id INT,
              time_entry_time_entry_type_id INT,
              cf_law_of_good varchar(255)
            )
            RETURNS TABLE(
              validates varchar(255)
            ) AS $$
            BEGIN
          	 RETURN QUERY select cast(\'OK\' as varchar) as validates;
            END;
            $$ LANGUAGE plpgsql;'
          when 'sqlserver'
            '
            CREATE PROCEDURE IF NOT EXISTS spr_ayty_validate_update_issue_before
            (
              @issue_id INT,
              @assigned_to_id_old INT,
              @assigned_to_ayty_role_id_old INT,
              @assigned_to_id INT,
              @assigned_to_ayty_role_id INT,
              @status_id_old INT,
              @status_id INT,
              @assigned_to_bd_id INT,
              @assigned_to_net_id INT,
              @assigned_to_test_id INT,
              @assigned_to_areq_id INT,
              @assigned_to_aneg_id INT,
              @assigned_to_inf_id INT,
              @fixed_version_id INT,
              @due_date varchar(255),
              @cf_request_type varchar(255),
              @cf_solution_type varchar(255),
              @cf_estimation_bd_old varchar(255),
              @cf_estimation_bd varchar(255),
              @cf_estimation_sys_old varchar(255),
              @cf_estimation_sys varchar(255),
              @cf_estimation_sys_col_old varchar(255),
              @cf_estimation_sys_col varchar(255),
              @cf_estimation_inf_old varchar(255),
              @cf_estimation_inf varchar(255),
              @cf_remainder_time_bd_old varchar(255),
              @cf_remainder_time_bd varchar(255),
              @cf_remainder_time_sys_old varchar(255),
              @cf_remainder_time_sys varchar(255),
              @cf_remainder_time_sys_col_old varchar(255),
              @cf_remainder_time_sys_col varchar(255),
              @cf_remainder_time_inf_old varchar(255),
              @cf_remainder_time_inf varchar(255),
              @cf_quality_ticket_to_reach_areq varchar(255),
              @cf_quality_ticket_to_reach_des varchar(255),
              @cf_release_general_internal varchar(255),
              @cf_release_col_internal varchar(255),
              @cf_status_post_delivery varchar(255),
              @cf_instructions_to_deploy varchar(255),
              @notes varchar(255),
              @current_user_id INT,
              @current_user_ayty_role_id INT,
              @time_entry_hours varchar(255),
              @time_entry_spent_on varchar(255),
              @time_entry_comments varchar(255),
              @time_entry_activity_id INT,
              @time_entry_time_entry_type_id INT,
              @cf_law_of_good varchar(255)
            )
            AS
            BEGIN
          	 select \'OK\' as validates;
            END'
          end
    begin
      execute <<-__EOI
        #{sql}
      __EOI
    rescue => exception
      p "Error to create procedure: #{exception}"
      ActiveRecord::Base.connection.execute 'ROLLBACK'
    end
  end

  def self.down
    # TODO: por agora julguei desnecessario se preocupar com a gerencia
    # deste objeto, por isso apenas criarei se nao existir
    # execute "DROP FUNCTION IF EXISTS spr_ayty_validate_update_issue_before(
    # integer, integer, integer, integer, integer, integer, integer, integer,
    # integer, integer, integer, integer, integer, integer, character varying,
    # character varying, character varying, character varying,
    # character varying, character varying, character varying,
    # character varying, character varying, character varying,
    # character varying, character varying, character varying,
    # character varying, character varying, character varying,
    # character varying, character varying, character varying,
    # character varying, character varying, character varying,
    # character varying, character varying, character varying,
    # character varying, integer, integer, character varying, character varying,
    # character varying, integer, integer, character varying);"
  end
end

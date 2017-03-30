# select para teste no postgresql
# select * from spr_ayty_validate_update_issue_after(
# null,null,null,null,null,null,null,null,'',null,null);
class CreateProcedureSprAytyValidateUpdateIssueAfter < ActiveRecord::Migration
  def self.up
    sql = case ActiveRecord::Base.connection_config[:adapter]
          when 'postgresql'
            '
            CREATE FUNCTION spr_ayty_validate_update_issue_after(
              issue_id INT,
              assigned_to_id_old INT,
              assigned_to_ayty_role_id_old INT,
              assigned_to_id INT,
              assigned_to_ayty_role_id INT,
              status_id_old INT,
              status_id INT,
              assigned_to_inf_id INT,
              cf_status_post_delivery VARCHAR(255),
              current_user_id INT,
              current_user_ayty_role_id INT
            )
            RETURNS void AS $$
            BEGIN
            END;
            $$ LANGUAGE plpgsql;'
          when 'sqlserver'
            '
            CREATE PROCEDURE IF NOT EXISTS spr_ayty_validate_update_issue_after(
              @issue_id INT,
              @assigned_to_id_old INT,
              @assigned_to_ayty_role_id_old INT,
              @assigned_to_id INT,
              @assigned_to_ayty_role_id INT,
              @status_id_old INT,
              @status_id INT,
              @assigned_to_inf_id INT,
              @cf_status_post_delivery VARCHAR(255),
              @current_user_id INT,
              @current_user_ayty_role_id INT
            )
            AS
            BEGIN
              print \'OK\';
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
    # execute "DROP FUNCTION IF EXISTS spr_ayty_validate_update_issue_after(
    # integer, integer, integer, integer, integer, integer, integer, integer,
    # character varying, integer, integer);"
  end
end

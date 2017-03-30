# select para teste no postgresql
# select * from spr_redmine_list_pending(null,null,null,'');
class CreateProcedureSprRedmineListPending < ActiveRecord::Migration
  def self.up
    sql = case ActiveRecord::Base.connection_config[:adapter]
          when 'postgresql'
            '
            CREATE FUNCTION spr_redmine_list_pending(
              p_must_show_issue_pending_items INT,
              p_must_show_checklist_pending_items INT,
              p_id_issue INT,
              p_nm_email_user VARCHAR(255)
            )
            RETURNS TABLE(
              COLUMN_A VARCHAR(255),
              COLUMN_B VARCHAR(255),
              COLUMN_C VARCHAR(255)
            ) AS $$
            BEGIN
              RETURN QUERY SELECT CAST(\'Teste\' AS VARCHAR) AS COLUMN_A, CAST(\'Value\' AS VARCHAR) AS COLUMN_B, CAST(\'Columns\' AS VARCHAR) AS COLUMN_C;
            END;
            $$ LANGUAGE plpgsql;'
          when 'sqlserver'
            '
            CREATE PROCEDURE IF NOT EXISTS spr_redmine_list_pending
            (
              @p_must_show_issue_pending_items INT,
              @p_must_show_checklist_pending_items INT,
              @p_id_issue INT,
              @p_nm_email_user VARCHAR(255)
            )
            AS
            BEGIN
          	  SELECT CAST(\'Teste\' AS VARCHAR) AS COLUMN_A, CAST(\'Value\' AS VARCHAR) AS COLUMN_B, CAST(\'Columns\' AS VARCHAR) AS COLUMN_C;
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
    # execute "DROP FUNCTION IF EXISTS spr_redmine_list_pending(null,null,null,'')"
  end
end

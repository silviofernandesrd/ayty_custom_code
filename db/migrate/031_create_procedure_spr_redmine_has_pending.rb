# select para teste no postgresql
# select * from spr_redmine_has_pending(null,'');
class CreateProcedureSprRedmineHasPending < ActiveRecord::Migration
  def self.up
    sql = case ActiveRecord::Base.connection_config[:adapter]
          when 'postgresql'
            '
            CREATE FUNCTION spr_redmine_has_pending(
              p_id_issue INT,
              p_nm_email_user varchar(255)
            )
            RETURNS TABLE(
              HAS_ISSUE_PENDING_ITEMS INT,
              HAS_CHECKLIST_PENDING_ITEMS INT
            ) AS $$
            BEGIN
              RETURN QUERY SELECT 1 AS HAS_ISSUE_PENDING_ITEMS, 1 AS HAS_CHECKLIST_PENDING_ITEMS;
            END;
            $$ LANGUAGE plpgsql;'
          when 'sqlserver'
            '
            CREATE PROCEDURE IF NOT EXISTS spr_redmine_has_pending
            (
              @p_id_issue INT,
              @p_nm_email_user varchar(255)
            )
            AS
            BEGIN
          	 SELECT 1 AS HAS_ISSUE_PENDING_ITEMS, 1 AS HAS_CHECKLIST_PENDING_ITEMS;
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
    # execute "DROP FUNCTION IF EXISTS spr_redmine_has_pending(null,'')"
  end
end

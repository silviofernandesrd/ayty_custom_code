module Ayty::AytyManagement
  extend ActiveSupport::Concern

  attr_accessor :has_pending, :has_checklist

  def verify_pendencies
    # executa a procedure e pega o resultado
    result = ActiveRecord::Base.connection.exec_query(sql_to_validates)

    # valida retorno
    validate = result.first if result
    return unless validate
    @has_pending = validate['has_issue_pending_items']
    @has_checklist = validate['has_checklist_pending_items']
  end

  def show_pending
    # executa a procedure e pega o resultado
    result = ActiveRecord::Base.connection.exec_query(sql_to_pending)
    result.rows.unshift(result.columns)
  end

  def show_checklist
    # executa a procedure e pega o resultado
    result = ActiveRecord::Base.connection.exec_query(sql_to_checklist)
    result.rows.unshift(result.columns)
  end

  private

  def sql_to_validates
    "#{begin_sql_with} spr_redmine_has_pending #{id}, '#{usermail}'"
  end

  def sql_to_pending
    "#{begin_sql_with} spr_redmine_list_pending 1, 0, #{id}, '#{usermail}'"
  end

  def sql_to_checklist
    "#{begin_sql_with} spr_redmine_list_pending 0, 1, #{id}, '#{usermail}'"
  end

  def usermail
    User.current.mail || 'nomail'
  end

  def begin_sql_with
    case ActiveRecord::Base.connection_config[:adapter]
    when 'postgresql'
      'select * from'
    when 'sqlserver'
      'exec'
    end
  end
end

module Ayty::AytyManagement
  extend ActiveSupport::Concern

  attr_accessor :has_pending, :has_checklist

  def verify_pendencies
    # executa a procedure e pega o resultado
    result = ActiveRecord::Base.connection.exec_query(sql_to_validates)

    # valida retorno
    validate = result.first if result
    return unless validate
    @has_pending = validate['HAS_ISSUE_PENDING_ITEMS']
    @has_checklist = validate['HAS_CHECKLIST_PENDING_ITEMS']
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
    case ActiveRecord::Base.connection_config[:adapter]
    when 'postgresql'
      "select * from spr_redmine_has_pending(#{id}, '#{usermail}')"
    when 'sqlserver'
      "exec spr_redmine_has_pending #{id}, '#{usermail}'"
    end
  end

  def sql_to_pending
    case ActiveRecord::Base.connection_config[:adapter]
    when 'postgresql'
      "select * from spr_redmine_list_pending(1, 0, #{id}, '#{usermail}')"
    when 'sqlserver'
      "exec spr_redmine_list_pending 1, 0, #{id}, '#{usermail}'"
    end
  end

  def sql_to_checklist
    case ActiveRecord::Base.connection_config[:adapter]
    when 'postgresql'
      "select * from spr_redmine_list_pending(0, 1, #{id}, '#{usermail}')"
    when 'sqlserver'
      "exec spr_redmine_list_pending 0, 1, #{id}, '#{usermail}'"
    end
  end

  def usermail
    User.current.mail || 'nomail'
  end
end

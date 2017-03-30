##### AYTYCRM - Silvio Fernandes #####
require_dependency 'custom_field'

module AytyCustomFieldPatch
  extend ActiveSupport::Concern

  included do
    class_eval do
      belongs_to :ayty_access_level, :foreign_key => :ayty_access_level_id

      scope :ayty_filter_access_level, ->(user) { joins(:ayty_access_level).
                                                  where("#{AytyAccessLevel.table_name}.level <= :u", {:u => user.ayty_access_level.level}) }

      #scope :visible, lambda {|*args|
      #  user = args.shift || User.current
      #  if user.admin?
      #    # nop
      #  elsif user.memberships.any?
      #    joins(:ayty_access_level).
      #        where("#{table_name}.visible = ? OR #{table_name}.id IN (SELECT DISTINCT cfr.custom_field_id FROM #{Member.table_name} m" +
      #              " INNER JOIN #{MemberRole.table_name} mr ON mr.member_id = m.id" +
      #              " INNER JOIN #{table_name_prefix}custom_fields_roles#{table_name_suffix} cfr ON cfr.role_id = mr.role_id" +
      #              " WHERE m.user_id = ?)",
      #          true, user.id).
      #        where("#{AytyAccessLevel.table_name}.level <= :u", {:u => user.ayty_access_level.level})
      #  else
      #    where(:visible => true)
      #  end
      #}
    end
  end

  # metodo que retorna o nivel de acesso mais baixo caso nenhum valor esteja associado
  def ayty_access_level
    super || AytyAccessLevel.order("level ASC").first
  end
end

CustomField.send :include, AytyCustomFieldPatch

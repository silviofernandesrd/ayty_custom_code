##### AYTYCRM - Silvio Fernandes #####

module Redmine
  module Acts
    module Watchable
      module InstanceMethods

        #override
        #para excluir os usuarios que nao tenham acesso de acordo com o acesso de quem esta abrindo o ticket
        def notified_watchers

          notified = watcher_users.active.to_a
          notified.reject! {|user| user.mail.blank? || user.mail_notification == 'none'}
          if respond_to?(:visible?)
            notified.reject! {|user| !visible?(user)}
          end

          # remove usuarios que tenham nivel de acesso menor que o nivel de acesso de quem esta logado
          if User.current && User.current.ayty_access_level
            notified.reject! {|user| user.ayty_access_level.level < User.current.ayty_access_level.level}
          end

          notified
        end

      end
    end
  end
end
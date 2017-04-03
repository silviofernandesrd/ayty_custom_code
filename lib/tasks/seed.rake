desc <<-END_DESC
Seed project Ayty
Example:
  rake redmine:ayty_custom_code:seed RAILS_ENV=production
END_DESC
require File.expand_path(
  File.dirname(__FILE__) + '/../../../../config/environment'
)

namespace :redmine do
  namespace :ayty_custom_code do
    task seed: :environment do
      p 'Para que o plugin com códigos customizados para Ayty funcione'\
      ' corretamente, iremos executar alguns passos para deixarmos o ambiente'\
      ' pronto para uso ;)'
      p 'Acompanhe os passos abaixo:'
      p '- criando um nivel de acesso default'
      access_level_default = AytyAccessLevel.find_or_create_by(
        name: 'Default'
      ) do |access_level|
        access_level.level = 0
        access_level.ayty_access = false
      end
      p '- criando um nivel de acesso ayty'
      AytyAccessLevel.find_or_create_by(name: 'Ayty') do |access_level|
        access_level.level = 1
        access_level.ayty_access = true
      end
      p '- associando todos os usuários da base ao nivel de acesso default'
      User.find_each do |user|
        user.ayty_access_level = access_level_default
        user.save
      end
      p '- criando lastnames'
      [
        '- Adm', '- An.Apl', '- An.Neg', '- An.Req', '- An.Sist', '- BD',
        '- Bk.Of', '- C. Post', '- Cliente', '- Comercial', '- Coord Seg Inf',
        '- Coord TI', '- Diretor', '- Ejec. Cuentas', '- Ger HD', '- Ger.Des',
        '- Ger.TI', '- HD', '- Infra', '- PMO', '- RH', '- Sup. Tec.', '- Te.S',
        '- Ti', 'Anonymous', 'AYTY CRM'
      ].each do |lastname|
        AytyLastname.find_or_create_by(lastname: lastname, active: true)
      end
      p '- aplicando tema de estilos da Ayty'
      # este passo requer que a pasta com os estilos da ayty estejam em:
      # redmine_root_folder/public/themes
      Setting.find_or_create_by(name: 'ui_theme') do |theme_ayty|
        theme_ayty.value = 'ayty'
      end
    end
  end
end

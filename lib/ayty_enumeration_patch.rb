##### AYTYCRM - Silvio Fernandes #####
require_dependency 'enumeration'

module AytyEnumerationPatch
  extend ActiveSupport::Concern

  included do
    class_eval do
      # limpas todas validacoes
      clear_validators!

      # insere as validacoes que existiam antes
      validates_presence_of :name
      validates_uniqueness_of :name, :scope => [:type, :project_id]

      # Alterar tamanho do campo de 30 para 100
      validates_length_of :name, :maximum => 100
    end
  end
end

Enumeration.send :include, AytyEnumerationPatch
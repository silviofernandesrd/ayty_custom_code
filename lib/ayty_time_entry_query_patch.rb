##### AYTYCRM - Silvio Fernandes #####
require_dependency 'time_entry_query'

module AytyTimeEntryQueryPatch
  extend ActiveSupport::Concern

  included do
    class_eval do

      # coluna tipo de apontamento nas listagens
      self.available_columns += [
          QueryColumn.new(:ayty_time_entry_type, :sortable => false),
      ]

      alias_method_chain :default_columns_names, :ayty_time_entry_types

    end
  end

  # override
  def default_columns_names_with_ayty_time_entry_types
    default_columns_names_without_ayty_time_entry_types

    @default_columns_names.push(:ayty_time_entry_type)
  end

end

TimeEntryQuery.send :include, AytyTimeEntryQueryPatch

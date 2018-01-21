require 'to_wa/version'
require 'to_wa/exceptions'
require 'to_wa/configuration'
require 'to_wa/easy_hash_access'
require 'to_wa/builder'
require 'to_wa/core'

module ToWa
  include ::ToWa::Configuration

  def to_wa(ex)
    where(
      ::ToWa::Builder.new(
        arel_table: arel_table,
        permitted_columns: permitted_to_wa_columns,
        permitted_operators: permitted_to_wa_operators,
        permitted_specified_columns: permitted_to_wa_specified_columns,
        ex: ex,
      ).execute!,
    )
  end
end

module Kernel
  def ToWa(arel_table, ex) # rubocop:disable Naming/MethodName
    ::ToWa::Builder.new(restricted: false, arel_table: arel_table, ex: ex).execute!
  end
end

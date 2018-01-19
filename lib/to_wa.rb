require 'to_wa/version'
require 'active_record'

module ToWa
  require 'to_wa/builder'
  require 'to_wa/core'

  def to_wa(o)
    ::ToWa::Core.to_wa(self, o)
  end

  def to_wa_raw(arel_table, o)
    ToWa(arel_table, o)
  end
end

module Kernel
  def ToWa(arel_table, o) # rubocop:disable Naming/MethodName
    ::ToWa::Core.to_wa_raw(arel_table, o)
  end
end

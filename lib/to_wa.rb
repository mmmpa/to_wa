require 'to_wa/version'
require 'to_wa/easy_hash_access'
require 'to_wa/builder'
require 'to_wa/core'

module ToWa
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

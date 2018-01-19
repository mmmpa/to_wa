module ToWa
  module Core
    extend ::ToWa::Builder

    COMPARISON = {
      '==' => 'eq',
      '=' => 'eq',
      'eq' => 'eq',
      '!=' => 'not_eq',
      '<>' => 'not_eq',
      'ne' => 'not_eq',
      '>' => 'gt',
      'gt' => 'gt',
      '>=' => 'gteq',
      'gteq' => 'gteq',
      '<' => 'lt',
      'lt' => 'lt',
      '<=' => 'lteq',
      'lteq' => 'lteq',
      'matches' => 'matches',
      'like' => 'matches',
      'in' => 'in',
      'between' => 'between',
    }.freeze

    LOGICAL = {
      '&&' => 'and',
      'and' => 'and',
      '||' => 'or',
      'or' => 'or',
      'not' => 'not',
    }.freeze

    OPERATORS = COMPARISON.merge(LOGICAL)

    ALLOW = Set.new(OPERATORS.keys)
  end
end

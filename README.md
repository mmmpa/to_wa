[![CircleCI](https://circleci.com/gh/mmmpa/to_wa.svg?style=svg)](https://circleci.com/gh/mmmpa/to_wa)
[![Maintainability](https://api.codeclimate.com/v1/badges/82a4f55558f3066ad63f/maintainability)](https://codeclimate.com/github/mmmpa/to_wa/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/82a4f55558f3066ad63f/test_coverage)](https://codeclimate.com/github/mmmpa/to_wa/test_coverage)

# ToWa

"ToWa" adds `to_wa` method to ActiveRecord based class. `to_wa` method can receive `Hash` or `JSON` argument and add them as `Where` to ActiveRecord query.

# Installation

```ruby
gem 'to_wa'
```

```console
bundle install
```

## Use all columns and operators

```ruby
class TestRecord < ActiveRecord::Base
  extend ToWa

  permit_all_to_wa_operators!
  permit_all_to_wa_columns!

  # read section: Use specific table columns as left and right
  permit_all_to_wa_specified_columns!
end
```

## Or specify columns and operators

```ruby
class TestRecord < ActiveRecord::Base
  extend ToWa

  permit_to_wa_columns :a, :b, :x
  permit_to_wa_operators :eq, :ne

  # read section: Use specific table columns as left and right
  permit_to_wa_specified_columns foo_records: [:a], bar_records: [:b]
end
```

## Simple usage

```ruby
TestRecord.to_wa(
  {
    'and': [
      { '=': ['name', 'ToWa'] },
      { '=': ['gender', 'male'] }
    ]
  }
).to_sql
#=> "SELECT `test_records`.* FROM `test_records` WHERE (`test_records`.`name` = 'ToWa' AND `test_records`.`genderb` = 'malebbb')"
```

# Basic syntax

```js
{ "operator": valuesArray }
```

## Comparison operators

They receive `[left, right]`.

```js
{ "=": ["name", "ToWa"] } // means "name eq ToWa"
```

|alias|operator||
|:---|:---|:---|
==|eq|
=|eq|
eq|eq|
!=|not_eq|
<>|not_eq|
ne|not_eq|
\>|gt|
gt|gt|
\>=|gteq|
gteq|gteq|
<|lt|
lt|lt|
<=|lteq|
lteq|lteq|
matches|matches|`right like "%right%"` (% in right will be escaped.)
like|matches|
in|in|`right` must be Array. `left in (right)`
between|between|`right` must be Array. `left between right[0] and right[1]`

## Logical Operators

They receive data list.

```js
{
  "and": [
    { "=": ["name", "ToWa"] },
    { "=": ["gender", "male"] },
    {
      "or": [
        { "<": ["age", 12] },
        { ">": ["age", 16] }
      ]
    }
  ]
} // means "(name EQ ToWa AND name EQ ToWa AND (age < 12 OR age > 16))"
```

|alias|operator||
|:---|:---|:---|
&&|and|
and|and|
\|\||or|
or|or|
not|not|It must receive Array that includes only one data. `{ "not": [{ "name": "ToWa" }] }`

# Usage

(Ofcourse, `ActiveRecord::Relation` will be provided after `to_wa` without `to_sql`.)

```ruby
TestRecord.to_wa({ '=': ['name', 'ToWa'] }).to_sql
#=> SELECT `test_records`.* FROM `test_records` WHERE `test_records`.`name` = 'ToWa'
```

```ruby
TestRecord.to_wa(
  {
    'and': [
      { '=': ['name', 'ToWa'] },
      { '=': ['gender', 'male'] }
    ]
  }
).to_sql
#=> "SELECT `test_records`.* FROM `test_records` WHERE (`test_records`.`name` = 'ToWa' AND `test_records`.`genderb` = 'male')"
```

```ruby
TestRecord.to_wa(
  {
    'and': [
      {
        'or': [
          { '=': ['name', 'ToWa'] },
          { '=': ['name', 'to_wa'] }
        ]
      },
      { '=': ['gender', 'male'] }
    ]
  }
).to_sql
#=> "SELECT `test_records`.* FROM `test_records` WHERE ((`test_records`.`name` = 'ToWa' OR `test_records`.`name` = 'to_wa') AND `test_records`.`gender` = 'male')"
```

## Use specific table columns as left and right

```ruby
class TestRecord < ActiveRecord::Base
  extend ToWa
  has_many :users
end

class User < ActiveRecord::Base
end

TestRecord.left_outer_joins(:users).to_wa(
  {
    '>': [
      { 'col': ['users', 'left_arm_length'] },
      { 'col': ['users', 'right_arm_length'] }
    ]
  }
).to_sql
#=> "SELECT `test_records`.* FROM `test_records` LEFT OUTER JOIN `users` ON `users`.`test_record_id` = `test_records`.`id` WHERE (`users`.`left_arm_length` > `users`.`right_arm_length`)"
```

## Working with other query

```ruby
TestRecord.select(:id).to_wa({ '=': ['name', 'ToWa'] }).order(id: :desc).to_sql
#=> "SELECT `test_records`.`id` FROM `test_records` WHERE `test_records`.`name` = 'ToWa' ORDER BY `test_records`.`id` DESC"
```

## Providing Arel::Nodes without ActiveRecord based class

```ruby
a = ToWa(Arel::Table.new('test_records'), { '=': ['name', 'ToWa'] })

a.class
#=> Arel::Nodes::Equality
a.to_sql
#=> "`test_records`.`name` = 'ToWa'"
TestRecord.where(a).to_sql
#=> "SELECT `test_records`.* FROM `test_records` WHERE `test_records`.`name` = 'ToWa'"
```

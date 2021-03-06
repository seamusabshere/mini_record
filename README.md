# DEPRECATED

The old `mini_record-compat` gem has been deprecated in favor of [`active_record_inline_schema`](https://github.com/seamusabshere/active_record_inline_schema).

Please use [`active_record_inline_schema`](https://github.com/seamusabshere/active_record_inline_schema) or [original mini_record](https://github.com/DAddYE/mini_record) instead of `mini_record-compat`. 

# DEPRECATED

MiniRecord is a micro extension for our `ActiveRecord` gem.
With MiniRecord you can add the ability to create columns outside the default `schema.rb`, directly
in your **model** in a similar way that should know in others projects
like  DataMapper, MongoMapper or MongoID.

My inspiration come from this handy [project](https://github.com/pjhyett/auto_migrations).

## Features

* Define columns/properties inside your model
* Perform migrations automatically
* Auto upgrade your schema, so if you know what you are doing you don't lost your existing data!
* Add, Remove, Change Columns; Add, Remove, Change indexes

## Instructions

What you need is to move/remove your `db/schema.rb`.
This avoid conflicts.

Add to your `Gemfile`:

``` rb
gem 'mini_record'
```

That's all!

## Examples

Remember that inside properties you can use all migrations methods,
see [documentation](http://api.rubyonrails.org/classes/ActiveRecord/Migration.html)

``` rb
class Post < ActiveRecord::Base
  col :title_en, :title_jp
  col :description_en, :description_jp, :as => :text
  col :permalink, :index => true, :limit => 50
  col :comments_count, :as => :integer
  col :category, :as => :references, :index => true
end
Post.auto_upgrade!
```

Instead of `:as => :my_type` you can use `:type => :my_type`

Option `:as` or `:type` if not provided is `:string` by default, you can use all ActiveRecord types:

``` rb
:primary_key, :string, :text, :integer, :float, :decimal, :datetime, :timestamp, :time, :date, :binary, :boolean
:references, :belongs_to, :polymorphic, :timestamp
```

You can provide others ActiveRecord options like:

``` rb
:limit, :default, :null, :precision, :scale

# example
class Foo < ActiveRecord::Base
  col :title, :default => "MyTitle" # :as => :string is by default
  col :price, :as => :decimal, :scale => 8, :precision => 2
end
```

See [ActiveRecord::TableDefinition](http://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/TableDefinition.html) 
for more details.

Finally, when you execute `MyModel.auto_upgrade!`, missing columns, indexes and tables will be created on the fly.
Indexes and columns present in the db but **not** in your model schema will be **deleted*** also in your db.

### Single Table Inheritance

MiniRecord as ActiveRecord support STI plus some goodness, see our specs for more details.

### Adding a new column

Super easy, open your model and just add it:

``` rb
class Post < ActiveRecord::Base
  col :title
  col :body, :as => :text # <<- this
  col :permalink, :index => true
  col :comments_count, :as => :integer
  col :category, :as => :references, :index => true
end
Post.auto_upgrade!
```

So now when you invoke `MyModel.auto_upgrade!` you should see a SQL query like `ALTER TABLE` that mean that your existing
records are happy and safe.

### Removing a column

It's exactly the same, but the column will be _really_ deleted without affect other columns.

### Change columns

It's not possible for us know when/what column you have renamed, but we can know if you changed the `type` so
if you change `t.string :name` to `t.text :name` we are be able to perform an `ALTER TABLE`

### Add/Remove indexes

In the same ways we manage columns MiniRecord will detect new indexes and indexes that needs to be removed.
So when you perform `MyModel.auto_upgrade!` a SQL command like:

``` SQL
PRAGMA index_info('index_people_on_name')
CREATE INDEX "index_people_on_surname" ON "people" ("surname")
```

Note that writing it in DSL way you have same options as `add_index` so you are be able to write:

``` rb
class Fox < ActiveRecord::Base
  col :foo, :index => true
  col :foo, :index => :custom_name
  col :foo, :index => [:foo, :bar]
  col :foo, :index => { :column => [:branch_id, :party_id], :unique => true, :name => 'by_branch_party' }
end
```

That is the same of:

``` rb
class Fox < ActiveRecord::Base
  col :foo
  add_index :foo
  add_index :custom_name
  add_index [:foo, :bar]
  add_index [:branch_id, :party_id], :unique => true, :name => 'by_branch_party'
end
```

## Warnings

This software is not super well tested in a production project.
Im stated to using it in two customer's projects without any problem.

## TODO

* reduce the number of methods we add to ActiveRecord::Base objects

## Author

DAddYE, you can follow me on twitter [@daddye](http://twitter.com/daddye) or take a look at my site [daddye.it](http://www.daddye.it)

## Copyright

Copyright (C) 2011 Davide D'Agostino - [@daddye](http://twitter.com/daddye)

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
associated documentation files (the “Software”), to deal in the Software without restriction, including without
limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software,
and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM,
DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

# be sure to set up activerecord before you require this helper

class Person < ActiveRecord::Base
  include SpecHelper
  schema do |s|
    s.string :name
  end
end

class Post < ActiveRecord::Base
  include SpecHelper

  col :title
  col :body
  col :category, :as => :references
  belongs_to :category
end

class Category < ActiveRecord::Base
  include SpecHelper

  col :title
  has_many :posts
end

class Animal < ActiveRecord::Base
  include SpecHelper

  col :name, :index => true
  add_index :id
end

class Pet < ActiveRecord::Base
  include SpecHelper

  col :name, :index => true
end
class Dog < Pet; end
class Cat < Pet; end

class Vegetable < ActiveRecord::Base
  include SpecHelper

  self.primary_key = 'latin_name'
  
  col :latin_name
  col :common_name
end

class Gender < ActiveRecord::Base
  include SpecHelper

  self.primary_key = 'name'
  
  col :name
end

class User < ActiveRecord::Base
  include SpecHelper
  self.inheritance_column = 'role' # messed up in 3.2.2
  col :name
  col :surname
  col :role
end
class Administrator < User; end
class Customer < User; end

class Fake < ActiveRecord::Base
  include SpecHelper
  col :name, :surname
  col :category, :group, :as => :references
end

class AutomobileMakeModelYearVariant < ActiveRecord::Base
  include SpecHelper
  col :make_model_year_name
  add_index :make_model_year_name
end

if ENV['DB_ADAPTER'] == 'mysql'
  class MyVarCols < ActiveRecord::Base
    include SpecHelper
    col :varb, :type => 'varbinary(255)'
    col :varc, :type => 'varchar(255)'
  end
end
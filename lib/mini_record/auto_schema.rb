require 'zlib'
module MiniRecord
  module AutoSchema
    def self.included(base)
      base.extend(ClassMethods)
    end
    
    module ClassMethods

      def table_definition
        return superclass.table_definition unless superclass == ActiveRecord::Base

        @_table_definition ||= begin
          ActiveRecord::ConnectionAdapters::TableDefinition.new(connection)
        end
      end

      def indexes
        return superclass.indexes unless superclass == ActiveRecord::Base

        @_indexes ||= {}
      end

      def col(*args)
        return unless connection?

        options = args.extract_options!
        type = options.delete(:as) || options.delete(:type) || :string
        args.each do |column_name|
          if table_definition.respond_to?(type)
            table_definition.send(type, column_name, options)
          else
            table_definition.column(column_name, type, options)
          end
          column_name = table_definition.columns[-1].name
          case index_name = options.delete(:index)
            when Hash
              add_index(options.delete(:column) || column_name, index_name)
            when TrueClass
              add_index(column_name)
            when String, Symbol, Array
              add_index(index_name)
          end
        end
      end

      def reset_table_definition!
        @_table_definition = nil
      end

      def schema
        reset_table_definition!
        yield table_definition
        table_definition
      end

      def add_index(column_name, options={})
        index_name = shorten_index_name connection.index_name(table_name, :column => column_name)
        indexes[index_name] = options.merge(:column => column_name, :name => index_name)
        index_name
      end

      def connection?
        !!connection
      rescue Exception => e
        puts "\e[31m%s\e[0m" % e.message.strip
        false
      end
      
      def shorten_index_name(name)
        if name.length < connection.index_name_length
          name
        else
          name[0..(connection.index_name_length-11)] + ::Zlib.crc32(name).to_s
        end
      end
      
      def sqlite?
        connection.adapter_name =~ /sqlite/i
      end
      
      def mysql?
        connection.adapter_name =~ /mysql/i
      end
      
      def postgresql?
        connection.adapter_name =~ /postgresql/i
      end

      def auto_upgrade!(create_table_options = '')
        return unless connection?
        
        # normally activerecord's mysql adapter does this
        if mysql?
          create_table_options ||= 'ENGINE=InnoDB'
        end

        non_standard_primary_key = if (primary_key_column = table_definition.columns.detect { |column| column.name.to_s == primary_key.to_s })
          primary_key_column.type != :primary_key
        end
          
        unless non_standard_primary_key
          table_definition.column :id, :primary_key
        end

        # Table doesn't exist, create it
        unless connection.table_exists? table_name
          
          # avoid using connection.create_table because in 3.0.x it ignores table_definition
          # and it also is too eager about adding a primary key column
          create_sql = "CREATE TABLE #{quoted_table_name} (#{table_definition.to_sql}) #{create_table_options}"
          
          if sqlite?
            connection.execute create_sql
            if non_standard_primary_key
              add_index primary_key, :unique => true
            end
          elsif postgresql?
            connection.execute create_sql
            if non_standard_primary_key
              # can't use add_index method because it won't let you do "PRIMARY KEY"
              connection.execute "ALTER TABLE #{quoted_table_name} ADD PRIMARY KEY (#{quoted_primary_key})"
            end
          elsif mysql?
            if non_standard_primary_key
              # only string keys are supported
              create_sql.sub! %r{#{connection.quote_column_name(primary_key)} varchar\(255\)([^,\)]*)}, "#{connection.quote_column_name(primary_key)} varchar(255)\\1 PRIMARY KEY"
              create_sql.sub! 'DEFAULT NULLPRIMARY KEY', 'PRIMARY KEY'
            end
            connection.execute create_sql
          end

          if connection.respond_to?(:schema_cache)
            connection.schema_cache.clear!
          end
          reset_column_information
        end

        # Add to schema inheritance column if necessary
        if descendants.present? && !table_definition.columns.any? { |column| column.name.to_s == inheritance_column.to_s }
          table_definition.column inheritance_column, :string
        end

        # Grab database columns
        fields_in_db = connection.columns(table_name).inject({}) do |hash, column|
          hash[column.name] = column
          hash
        end

        # Grab new schema
        fields_in_schema = table_definition.columns.inject({}) do |hash, column|
          hash[column.name.to_s] = column
          hash
        end

        # Remove fields from db no longer in schema
        (fields_in_db.keys - fields_in_schema.keys & fields_in_db.keys).each do |field|
          column = fields_in_db[field]
          connection.remove_column table_name, column.name
        end

        # Add fields to db new to schema
        (fields_in_schema.keys - fields_in_db.keys).each do |field|
          column  = fields_in_schema[field]
          options = {:limit => column.limit, :precision => column.precision, :scale => column.scale}
          options[:default] = column.default if !column.default.nil?
          options[:null]    = column.null    if !column.null.nil?
          connection.add_column table_name, column.name, column.type.to_sym, options
        end

        # Change attributes of existent columns
        (fields_in_schema.keys & fields_in_db.keys).each do |field|
          if field != primary_key #ActiveRecord::Base.get_primary_key(table_name)
            changed  = false  # flag
            new_type = fields_in_schema[field].type.to_sym
            new_attr = {}

            # First, check if the field type changed
            if (fields_in_schema[field].type.to_sym != fields_in_db[field].type.to_sym) and (fields_in_schema[field].type.to_sym != fields_in_db[field].sql_type.to_sym)
              # $stderr.puts "A(#{field}) - #{fields_in_schema[field].type.to_sym}"
              # $stderr.puts "B(#{field}) - #{fields_in_db[field].type.to_sym} - #{fields_in_db[field].sql_type.to_sym}"
              changed = true
            end

            # Special catch for precision/scale, since *both* must be specified together
            # Always include them in the attr struct, but they'll only get applied if changed = true
            new_attr[:precision] = fields_in_schema[field][:precision]
            new_attr[:scale]     = fields_in_schema[field][:scale]

            # Next, iterate through our extended attributes, looking for any differences
            # This catches stuff like :null, :precision, etc
            fields_in_schema[field].each_pair do |att,value|
              next if att == :type or att == :base or att == :name # special cases
              if !value.nil? && value != fields_in_db[field].send(att)
                # $stderr.puts "C(#{att}) - #{value.inspect}"
                # $stderr.puts "D(#{att}) - #{fields_in_db[field].send(att).inspect}"
                new_attr[att] = value
                changed = true
              end
            end

            # Change the column if applicable
            connection.change_column table_name, field, new_type, new_attr if changed
          end
        end

        # Remove old index
        indexes_in_db = connection.indexes(table_name).map(&:name)
        (indexes_in_db - indexes.keys).each do |name|
          connection.remove_index(table_name, :name => name)
        end

        # Add indexes
        indexes.each do |name, options|
          options = options.dup
          unless connection.indexes(table_name).detect { |i| i.name == name }
            connection.add_index(table_name, options.delete(:column), options)
          end
        end

        # Reload column information
        if connection.respond_to?(:schema_cache)
          connection.schema_cache.clear!
        end
        reset_column_information
      end
    end # ClassMethods
  end # AutoSchema
end # MiniRecord

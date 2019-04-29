require 'sqlite3'
require 'bloc_record/schema'

module Persistence
  def self.included(base)
    base.extend(ClassMethods)
  end

  def save
    self.save! rescue false
  end

  def save!
    unless self.id
      self.id = self.class.create(BlocRecord::Utility.instance_variables_to_hash(self)).id
      BlocRecord::Utility.reload_obj(self)
      return true
    end

    fields = self.class.attributes.map { |col| "#{col}=#{BlocRecord::Utility.sql_strings(self.instance_variable_get("@#{col}"))}" }.join(",")

    self.class.connection.execute <<-SQL
      UPDATE #{self.class.table}
      SET #{fields}
      WHERE id = #{self.id};
    SQL

    true
  end

  # Update One Attribute With an Instance Method
  def update_attribute(attribute, value)
    self.class.update(self.id, { attribute => value })
  end
  # update_attribute passes self.class.update its own id and a hash of the attributes that should be updated
  # self.class is used to gain access to an unknown object's class // We need this to call update since it is a class method rather than an instance method

  # Update Multiple Attributes With an Instance Method
  def update_attributes(updates)
    self.class.update(self.id, updates)
  end

  module ClassMethods
    def create(attrs)
      attrs = BlocRecord::Utility.convert_keys(attrs)
      attrs.delete "id"
      vals = attributes.map { |key| BlocRecord::Utility.sql_strings(attrs[key]) }

      connection.execute <<-SQL
        INSERT INTO #{table} (#{attributes.join ","})
        VALUES (#{vals.join ","});
      SQL

      data = Hash[attributes.zip attrs.values]
      data["id"] = connection.execute("SELECT last_insert_rowid();")[0][0]
      new(data)
    end
    # This method takes a hash called attrs
    # Its values are converted to SQL strings and mapped into an array (vals)
    # These values are used to form an INSERT INTO SQL statement.

      # Remember, attributes is an array of the column names,
      # while attrs is the hash passed in to the create method.
      # We defined attributes in schema.rb.


    # Update Multiple Attributes With a Class Method //  by incorporated ternary operator for nil values
    def update(ids, updates)
      updates = BlocRecord::Utility.convert_keys(updates) # convert the non-id parameters to an array.
      updates.delete "id"
      updates_array = updates.map { |key, value| "#{key}=#{BlocRecord::Utility.sql_strings(value)}" }
      # use map to convert updates to an array of strings where each string is in the format "KEY=VALUE"
      # This updates the specified columns in the database.

      if ids.class == Fixnum #non-floting number
        where_clause = "WHERE id = #{id};"
      elsif ids.class == Array
        where_clause = ids.empty? ? ";" : "WHERE id IN (#{ids.join(",")});"
        # ternary operator used. If nil, then we end the query using ;, otherwise we append the WHERE clause.
      else
        where_clause = ";"
      end


      connection.execute <<-SQL
        UPDATE #{table}
        SET #{updates_array * ","}
        #{where_clause}
      SQL

      #  UPDATE table_name
      # SET column1=value1, column2=value2, ...
      # WHERE id=id1;

      true
    end

    # Update Multiple Attributes on All Records
    def update_all(updates)
      update(nil, updates)
    end


  end #ends ClassMethods
end #ends Persistence

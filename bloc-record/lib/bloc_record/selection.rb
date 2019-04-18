require 'sqlite3'

module Selection

  # retrieve one record

  def find_one(id)
    row = connection.get_first_row <<-SQL
      SELECT #{columns.join ","}
      FROM #{table}
      WHERE id = #{id};
    SQL

    init_object_from_row(row)
  end

  # method that can handle multiple ids
    #id is joined into a string, which is passed into an SQL query that retrieves multiple records

  def find(*ids)
    if ids.length == 1
      find_one(ids.first)
    else
      rows = connection.execute <<-SQL
        SELECT #{columns.join ","}
        FROM #{table}
        WHERE id IN (#{ids.join(",")});
      SQL

      rows_to_array(rows)
    end
  end

  # return all records matching the given condition

  def find_by(attribute, value)
    rows = connection.execute <<-SQL
      SELECT #{columns.join ","}
      FROM #{table}
      WHERE #{attribute} = #{BlocRecord::Utility.sql_strings(value)};
    SQL

    rows_to_array(rows)
  end

  # returns more than one random object

  def take(num=1)
    if num > 1
      rows = connection.execute <<-SQL
        SELECT #{columns.join ","}
        FROM #{table}
        ORDER BY random()
        LIMIT #{num};
      SQL

      rows_to_array(rows)
    else
      take_one
    end
  end

  # we want to obtain a random contact each time we ask for one

  def take_one
    row = connection.get_first_row <<-SQL
      SELECT #{columns.join ","}
      FROM #{table}
      ORDER BY random()
      LIMIT 1;
    SQL

    init_object_from_row(row)
  end

  # return the first record

  def first
    row = connection.get_first_row <<-SQL
      SELECT #{columns.join ","}
      FROM #{table}
      ORDER BY id ASC
      LIMIT 1;
    SQL

    init_object_from_row(row)
  end

  # return the last record

  def last
    row = connection.get_first_row <<-SQL
      SELECT #{columns.join ","}
      FROM #{table}
      ORDER BY id DESC
      LIMIT 1;
    SQL

    init_object_from_row(row)
  end

  # we need the ability to retrieve all records
   # often necessary when you want to sort or filter data in a way
   # that's more complex or requires more expressive language than SQL can handle

  def all
    rows = connection.execute <<-SQL
      SELECT #{columns.join ","}
      FROM #{table};
    SQL

    rows_to_array(rows)
  end

  private

  # extract the code that converts a row into an object
    # We don't always know an object's id. Let's add a method to allow us to retrieve
    # records if we know the values of other attribues

  def init_object_from_row(row)
    if row
      data = Hash[columns.zip(row)]
      new(data)
    end
  end

  # this method maps the rows to an array of corresponding objects
    # The zip method is a Ruby method which pairs items in the first
    # object (columns) with items in the argument (row)

  def rows_to_array(rows)
    rows.map{ |row| new(Hash[columns.zip(row)]) }
  end
end
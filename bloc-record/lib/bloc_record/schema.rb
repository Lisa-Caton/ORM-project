require 'sqlite3'
require 'bloc_record/utility'

module Schema
  def table
    BlocRecord::Utility.underscore(name)
  end

  def schema
    unless @schema
      @schema = {}
      connection.table_info(table) do |col|
        @schema[col["name"]] = col["type"]
      end
    end
    @schema
  end

  # returns the column names of a table

  def columns
    schema.keys
  end

  # return the column names except id

  def attributes
    columns - ["id"]
  end

  # returns a count of records in a table

  def count
    connection.execute(<<-SQL)[0][0]
      SELECT COUNT(*) FROM #{table}
    SQL
  end
end
require 'sqlite3'
require 'active_support/inflector'
require 'pg'

module Associations
  def has_many(association)
    define_method(association) do
      # association will always be a plural noun
        # for example, :entries
        # self is an instance of AddressBook
      rows = self.class.connection.execute <<-SQL
        SELECT *
        FROM #{association.to_s.singularize}
        WHERE #{self.class.table}_id = #{self.id}
      SQL

      class_name = association.to_s.classify.constantize
      # we create a new class name. classify creates the appropriate string name ('Entry'), and constantize converts the string to the actual class (the Entry class).
      collection = BlocRecord::Collection.new


      rows.each do |row|
        collection << class_name.new(Hash[class_name.columns.zip(row)])
      end
      #  we iterate each SQL record returned, and serialize it into an Entry object, which is added to collection.

      collection

      # Using define_method is an example of metaprogramming, which is when a program programs itself. In this case, the dynamic addition of new methods is metaprogramming. The use of metaprogramming makes our code shorter, more flexible, and so meta.

    end # end define_method
  end # has_many

  def belongs_to(association)
    define_method(association) do
      # association will always be a singular noun
      association_name = association.to_s
      row = self.class.connection.get_first_row <<-SQL
        SELECT *
        FROM #{association_name}
        WHERE id = #{self.send(association_name + "_id")}
      SQL
      # .get_first_row instead of execute bc only 1 record will be returned
      # and bc there's only 1 object, we don't create a collection; we just return a serialized object.

      class_name = association_name.classify.constantize

      if row
        data = Hash[class_name.columns.zip(row)]
        class_name.new(data)
      end

    end # ends define_method
  end # ends belongs_to
end # end module

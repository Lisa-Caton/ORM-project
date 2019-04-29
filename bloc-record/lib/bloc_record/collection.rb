module BlocRecord
  class Collection < Array

    def update_all(updates)
      ids = self.map(&:id)
      self.any? ? self.first.class.update(ids, updates) : false
    end
   # update_all takes an array, referred to as: updates
   # use the ternary operator to see if there are any items in the array
   # If yes, retrieve the first item using self.first
   # Since update is a class method, we again use .class to access the class methods for this item and call update
   # returns true once the items are updated // returns false to signify that nothing was updated.

  end #end class
end #end module

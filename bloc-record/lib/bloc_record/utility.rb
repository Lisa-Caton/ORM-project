 module BlocRecord
  module Utility

    extend self

    # takes: ('testing_Testing')
    # updates to:  => "testing_testing"
    def underscore(camel_cased_word)
      string = camel_cased_word.gsub(/::/, '/')
      string.gsub!(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
      string.gsub!(/([a-z\d])([A-Z])/, '\1_\2')
      string.tr!("-", "_")
      string.downcase
    end


    # takes a string or numeric
    # updates to: '' a string!
    def sql_strings(value)
      case value
      when String
        "'#{value}'"
      when Numeric
        value.to_s
      else
        "null"
      end
    end


    # takes: (user_name: 'Samuel', group: 'expert')
    # updates to: => {"user_name"=>"Samel", "group"=>"expert"}
      # takes: (username: :asc)
      # updates to: =>  {"username"=>:asc}
    def convert_keys(options)
      options.keys.each { |k| options[k.to_s] = options.delete(k) if k.kind_of?(Symbol) }
      options
    end


    # takes: (@user_name)
    # updates to: => {}
    def instance_variables_to_hash(obj)
      Hash[obj.instance_variables.map { |var| ["#{var.to_s.delete('@')}", obj.instance_variable_get(var.to_s)] }]
    end


    # takes an object, finds its database record
    # then overwrites the instance variable values with the stored values from the database
    # will discard any unsaved changes to the given object
    def reload_obj(dirty_obj)
      persisted_obj = dirty_obj.class.find_one(dirty_obj.id)
      dirty_obj.instance_variables.each do |instance_variable|
        dirty_obj.instance_variable_set(instance_variable, persisted_obj.instance_variable_get(instance_variable))
      end
    end

  end
end

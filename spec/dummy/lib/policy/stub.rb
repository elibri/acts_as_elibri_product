module Policy
  class Stub
  
    def self.call(object, attribute, pre, post)
    
      ### policy must accept four arguments:
      ### object is symbol of object that inside which attribute is changing - it should be our name, not elibri one, for example on main level it would :product, inside contributors it will be :contributors etc.
      ### attribute is symbol of attribute that will change - it should be our name, not elibri one
      ### pre - value of attribute before potential update
      ### post - value of attribute after potential update
    
      ### Add policy body here
      return true ### policy should return true when it allows of update of attribute, or return false when it disallows that
    end
  
  end
end
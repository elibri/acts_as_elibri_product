module Policy
  class Contributor
  
    def self.call(object, attribute, pre, post)
      if object == :contributors
         if attribute == :last_name
           return false if pre == "Adam" && post == "Adas" ### allow any change of name of contributor unless, it change name Adam to Adas
         end
       end
       return true
    end
  
  end
end
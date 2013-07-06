class String
  def method_missing(method_name, *args, &block)
    return self.id if method_name == :eid
    super
  end
end
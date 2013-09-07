class String

  # Transform a CamelCase String to a snake_case String.
  #--
  # Code has been taken from ActiveRecord
  def snake_case
    self.to_s.gsub(/::/, '/').
    gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
    gsub(/([a-z\d])([A-Z])/,'\1_\2').
    tr("-", "_").
    downcase
  end

end
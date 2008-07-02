module EventArray
  def files
    collect { |x|  x.files }.flatten
  end
  
  def modified_files
    collect { |x|  x.modified_files }.flatten
  end
  
  def deleted_files
    collect { |x|  x.deleted_files }.flatten
  end
end

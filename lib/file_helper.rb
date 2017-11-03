module FileHelper
  def modify_plist(file)
    sanitarized_plist = IO.read(file).force_encoding("ISO-8859-1").encode("UTF-8")

    plist = Plist.parse_xml(sanitarized_plist)
    yield plist
  ensure
    plist_string = Plist::Emit.dump(plist)
    File.write(file, plist_string)
  end
end

class AudioFile < File
  def to_mp3(options={})
    options[:quality] ||= 0
    options[:cbr] ||= false
    options[:bitrate] ||= 320
    options[:output] ||= self.basename_with_path + '.mp3'
    options.merge!(tags_for_mp3) 
    cmd_options = []
    if options[:cbr]
      cmd_options << "--cbr -b #{options[:bitrate]}"
    else
      cmd_options << "-V#{options[:quality]}"
    end

    cmd_options << "--tt \"#{options[:title]}\"" if options[:title]
    cmd_options << "--ta \"#{options[:artist]}\"" if options[:artist]
    cmd_options << "--tl \"#{options[:album]}\"" if options[:album]
    cmd_options << "--ty \"#{options[:year]}\"" if options[:year]
    cmd_options << "--tn \"#{options[:track]}\"" if options[:track]
    cmd_options << "--tg \"#{options[:genre]}\"" if options[:genre]
    cmd_options << "--ti \"#{options[:picture]}\"" if options[:picture]

    cmd = "lame #{cmd_options.join(' ')} \"#{self.path}\" -o \"#{options[:output]}\""
    STDOUT << cmd
    system(cmd)
  end
  
  def to_ogg(options={})
    options[:quality] ||= 8
    options[:output] ||= self.basename_with_path + '.ogg'
    options.merge!(tags_for_mp3) 
    cmd_options = []

    cmd_options << "-t \"#{options[:title]}\"" if options[:title]
    cmd_options << "-a \"#{options[:artist]}\"" if options[:artist]
    cmd_options << "-l \"#{options[:album]}\"" if options[:album]
    cmd_options << "-d \"#{options[:year]}\"" if options[:year]
    cmd_options << "-N \"#{options[:track]}\"" if options[:track]
    cmd_options << "-G \"#{options[:genre]}\"" if options[:genre]
    cmd_options << "-q #{options[:quality]}"
    cmd = "oggenc2 #{cmd_options.join(' ')} \"#{self.path}\" -o \"#{options[:output]}\""
    system(cmd)
  end

  # Warning, doesn't do tags
  def to_m4a(options={})
    options[:quality] ||= 320
    options[:output] ||= self.basename_with_path + '.m4a'
    cmd = "afconvert -v \"#{self.path}\" -o \"#{options[:output]}\" -f m4af -d aac -b #{options[:quality]}000 -s 0"
    system(cmd)
  end
  
  def basename_with_path
    ext = File.extname(self.path)
    basename = File.basename(self.path, ext)
    return File.join(File.dirname(self.path), basename)
  end
end

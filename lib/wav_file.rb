class WavFile < AudioFile
  def flac_file
    flac_filename = self.basename_with_path + '.flac'
    if File.exists?(flac_filename)
      flac = FlacFile.open(flac_filename)
      return flac
    end
  end

  def tags_for_mp3
    return flac_file.tags_for_mp3 if flac_file
  end

  def picture 
    return flac.picture if flac_file
  end
end

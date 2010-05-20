require 'fileutils'
require File.join(File.dirname(__FILE__), 'wav_file')

class AudioDirectory < Dir
  attr_accessor :dirty_wavs
  

  def to_mp3(options={})
    self.convert_directory(:mp3, options)
  end
  
  def to_m4a(options={})
    self.convert_directory(:m4a, options)
  end
  
  # Converts directory to OGG
  def to_ogg(options={})
    self.convert_directory(:ogg, options)
  end
  
  # Converts a FLAC directory to WAV 
  def to_wav(options={})
    self.convert_directory(:wav, options)
  end

  def clean_dirty_wavs
    @dirty_wavs.each {|dirty_wav| File.delete(dirty_wav[0])}
  end
  
  def convert_directory(to, options={})
    puts options.inspect
    case to.to_s.downcase
    when 'mp3'
      if options[:cbr]
        conversion_type = "MP3 #{options[:bitrate]}"
      else
        conversion_type = "MP3 V#{options[:quality]}"
      end
    when 'ogg'
      conversion_type = "Ogg q8"
    when 'm4a'
      conversion_type = "AAC 320"
    else
      conversion_type = to.to_s.upcase
    end
    
    # remove (FLAC) from the filename if it is at the end
    pre_path_match = self.path[0..-1].match(/(.*)\(FLAC\)/)
    pre_path = pre_path_match ? pre_path_match[1] : self.path[0..-1]

    options[:output] ||= pre_path + "(#{conversion_type})/" # removes trailing slash and adds (WAV)
    puts options[:output]
    new_dir = AudioDirectory.mkdir(options[:output])

    self.each do |filename|
      case File.extname(filename)
      when '.flac'
        wav_file = File.join(self.path, File.basename(filename, '.flac'))+'.wav'

        # skip if a wav file exists in the folder
        next if File.exists?(wav_file) 

        flac = FlacFile.open(File.join(self.path, filename))
        output = File.join(options[:output], File.basename(flac.path, '.flac')) + ".#{to.to_s.downcase}"
        STDOUT << "Converting #{flac.path} to #{output}\n"
        flac.send("to_#{to}".to_sym, options.merge(:output => output))
        @dirty_wavs ||= []
        @dirty_wavs << flac.dirty_wavs
      when '.wav'
        wav = WavFile.open(File.join(self.path, filename))
        output = File.join(options[:output], File.basename(wav.path, '.wav')) + ".#{to.to_s.downcase}"
        unless File.exists?(output)
          STDOUT << "Converting #{wav.path} to #{output}\n"
          wav.send("to_#{to}".to_sym, options.merge(:output => output))
        end
      else
        if filename =~ /^\./ || File.extname(filename) == '.cue'
          #ignore
        else 
          STDOUT << "Copying #{filename} to #{options[:output]}\n"
          FileUtils.cp(File.join(self.path, filename), options[:output])
        end
      end
    end
  end
end

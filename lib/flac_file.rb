require File.join(File.dirname(__FILE__), 'audio_file')
require 'rubygems'
gem 'flacinfo-rb'
require 'flacinfo'

class FlacFile < AudioFile
  attr_accessor :dirty_wavs
  def initialize(args=nil)
    @dirty_wavs = []
    super(args)
  end

  def to_wav(options={})
    options[:output] ||= self.basename_with_path + '.wav'
    return options[:output] if File.exists?(options[:output])
    cmd = "flac -d  \"#{self.path}\" -o \"#{options[:output]}\""
    system(cmd)
    return options[:output]
  end
  
  def to_m4a(options={})
    wav_filename = self.to_wav
    wav = WavFile.open(wav_filename)
    wav.to_m4a(options)
    @dirty_wavs << wav_filename
  end
  
  def to_mp3(options={})
    wav_filename = self.to_wav
    wav = WavFile.open(wav_filename)
    wav.to_mp3(options)
    @dirty_wavs << wav_filename
  end
  
  def to_ogg(options={})
    wav_filename = self.to_wav
    wav = WavFile.open(wav_filename)
    wav.to_ogg(options)
    @dirty_wavs << wav_filename
  end
  
  def flac_info
    @flac_info ||= FlacInfo.new(self.path)
  end

  def tags_for_mp3
    tags = {}
    tags[:title] = flac_info.tags['TITLE']
    tags[:artist] = flac_info.tags['ARTIST']
    tags[:year] = flac_info.tags['DATE']
    tags[:album] = flac_info.tags['ALBUM']
    tags[:track] = flac_info.tags['TRACKNUMBER']
    tags[:genre] = flac_info.tags['GENRE']
    picture = flac_info.write_picture(:outfile => '/tmp/albumart') if flac_info.picture && flac_info.picture[1]
    ext_match = flac_info.picture[1]['mime_type'].match(/image\/(.*)/) if flac_info.picture && flac_info.picture[1] && flac_info.picture[1]['mime_type']
    picture_name = '/tmp/albumart.'+ext_match[1] if ext_match
    tags[:picture] = picture_name if picture_name && File.exists?(picture_name) && (File.size(picture_name) < 128*2**10)
    return tags 
  end

end

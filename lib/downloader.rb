require "downloader/version"
require 'fileutils'
require 'pathname'
require 'pp'

module GDC

  class Downloader

    attr_accessor :pattern

    def self.download(options={})
      d = GDC::Downloader.new(options)
      d.execute
    end

    def initialize(options={})
      @pattern    = options[:pattern] || "*"
      @source_dir = Pathname.new(options[:source_dir] || ".")
      @latest     = options[:latest] || false
      
      fail "You have to define target directory" if options[:target_dir].nil?
      @target_dir = Pathname.new(options[:target_dir])

    end

    def execute
      FileUtils::cd(@source_dir) do
        files = Dir.glob(@pattern)
        files = files.map {|file| Pathname.new(file).expand_path}
        if @latest
          last_file = files.sort_by {|f| File.mtime(f)}.last
          FileUtils::cp last_file.to_s, @target_dir.to_s
        else
          files.each do |path|
            FileUtils::cp path.to_s, @target_dir.to_s
          end
        end
      end
    end

  end

end

# GDC::Downloader.download({
#   :pattern      => "data*.csv",
#   :source_dir   => "/Users/fluke/test_src",
#   :target_dir   => "/Users/fluke/test_dst",
#   :latest       => true,
#   :check_index  => "name.idx"
# })
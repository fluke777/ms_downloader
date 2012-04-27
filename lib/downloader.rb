require "bundler/setup"
require "downloader/version"
require 'pry'
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
      @pattern          = options[:pattern] || "*"
      @exclude_pattern  = options[:exclude_pattern]
      @source_dir       = Pathname.new(options[:source_dir] || ".")
      @latest           = options[:latest] || false
      
      fail "You have to define target directory" if options[:target_dir].nil?
      @target_dir = Pathname.new(options[:target_dir]).expand_path

    end

    def execute
      FileUtils::cd(@source_dir) do
        files = Dir.glob(@pattern)
        files = files.map {|file| Pathname.new(file).expand_path}
        exclude_files = @exclude_pattern && Dir.glob(@exclude_pattern)
        exclude_files = exclude_files && exclude_files.map {|exclude_file| Pathname.new(exclude_file).expand_path}
        files = files - exclude_files unless exclude_files.nil?
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
#   :pattern            => "data*.csv",
#   :exclude_pattern    => "data3.csv",
#   :source_dir         => "/Users/fluke/test_src",
#   :target_dir         => "/Users/fluke/test_dst",
#   :latest             => true,
#   :check_index        => "name.idx"
# })
require "downloader/version"
require 'pry'
require 'fileutils'
require 'pathname'
require 'pp'
require 'net/sftp'

module GDC
  
  class Downloader
    
    attr_accessor :pattern
    
    def self.download(options={})
      d = GDC::Downloader.new(options)
      d.execute
    end
    
    def initialize(options={})
      @pattern          = options[:pattern] || "**/*"
      @file_list        = options[:file_list]
      @exclude_pattern  = options[:exclude_pattern]
      @source_dir       = Pathname.new(options[:source_dir] || ".").expand_path
      
      @occurrence       = options[:occurrence] || "all"
      fail "Occurrence have to be set to one of: latest, oldest, all or omitted." unless ["all", "latest", "oldest"].include?(@occurrence)
      
      fail "You have to define target directory" if options[:target_dir].nil?
      @target_dir = Pathname.new(options[:target_dir]).expand_path
      
    end
    
    def execute
      
      FileUtils::cd(@source_dir) do
        if !@file_list.nil? 
          check_existence
        else
          @file_list = Dir.glob(@pattern)
        end
        files = @file_list.map {|file| Pathname.new(file).expand_path}
        exclude_files = @exclude_pattern && Dir.glob(@exclude_pattern)
        exclude_files = exclude_files && exclude_files.map {|exclude_file| Pathname.new(exclude_file).expand_path}
        files = files - exclude_files unless exclude_files.nil?
        
        unless @occurrence == "all"
          sorted_files = files.sort_by {|f| File.mtime(f)}
          files = @occurrence == "latest" ? sorted_files.first : sorted_files.last
          files = [files]
        end
        
        files.each do |path|
          target = path.sub(@source_dir,@target_dir)
          FileUtils.mkdir_p(target.dirname)    
          FileUtils.cp(path, target) unless path.directory?
        end
        
      end
    end
    
    def check_existence
      missing = []
      @file_list.each do |file|
        missing << file unless File.exists?(file)
      end
      fail "Files - #{missing.join(',')} - are missing." unless missing.empty?
    end
    
  end

  class SftpDownloader
  
    def self.download(options={})
      d = GDC::SftpDownloader.new(options[:server], options[:password], options[:login], options[:pid])
      d.execute(options[:target_dir], options[:pattern], options[:exclude_pattern])
    end

    def initialize(server, password, login, pid)
      @server = server
      @password = password
      @login = login
      @pid = pid
    end

    # Download files satisfying given pattern
    def execute(target_dir, pattern, exclude_pattern = nil)
      target_dir = Pathname.new(target_dir).expand_path
      Net::SFTP.start(@server, @pid + '@' + @login, :password => @password, :auth_methods => ('password')) do |sftp|
        files = sftp.dir.glob(".", pattern)
        exclude_files = exclude_pattern.nil? ? [] : sftp.dir.glob(".", exclude_pattern)
        #file = files.min_by{|f| f.attributes.attributes[:mtime]}
        files.each do |file|
          sftp.download!(file.name, target_dir + file.name) unless exclude_files.include?(file)
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
#   :occurrence             => :true,  ..oldest,latest,all
#   :file_list          => ["file1.txt","file2.txt"]
# })
# has new data? method

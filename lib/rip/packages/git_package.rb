module Rip
  class GitPackage < Package
    include Sh::Git

    def initialize(source, version = nil, files = nil)
      if File.directory?(file = File.expand_path(source))
        source = file
      end

      super(source, version, files)
    end

    handles "file://", "git://", '.git'

    memoize :name
    def name
      source.split('/').last.chomp('.git')
    end

    def version
      @version
    end

    def exists?
      case source
      when /^file:/
        file_exists?
      when /^git:/
        remote_exists?
      when /\.git$/
        file_exists? || remote_exists?
      else
        false
      end
    end

    def fetch!
      if File.exists? cache_path
        Dir.chdir cache_path do
          git_fetch('origin')
        end
      else
        git_clone(source, cache_name)
      end
    end

    def unpack!
      Dir.chdir cache_path do
        git_reset_hard(version)
        git_submodule_init
        git_submodule_update
      end
    end

  private
    def file_exists?
      File.exists? File.join(source.sub('file://', ''), '.git')
    end

    def remote_exists?
      @version ||= "HEAD"
      if @version.size == 40 || @version.size == 7
        fetch!
        return Dir.chdir(cache_path) { git_cat_file(@version).size > 0 }
      end

      v = remote_refs.detect { |commit, ref|
        commit.include?(@version) || ref.include?(@version)
      }
      return nil unless v
      @version = v.first
    end

    memoize :remote_refs
    def remote_refs
      git_ls_remote(source).each_line.
        map { |l| l.chomp.split("\t") }
    end
  end
end

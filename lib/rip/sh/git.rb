module Rip
  module Sh
    module Git
      extend self

      def git_ls_remote(source, version = nil)
        `git ls-remote #{source} #{version} 2> /dev/null`
      end

      def git_clone(source, cache_name)
        `git clone #{source} #{cache_name}`
      end

      def git_fetch(remote)
        `git fetch #{remote}`
      end

      def git_reset_hard(version)
        `git reset --hard #{version}`
      end

      def git_submodule_init
        `git submodule init`
      end

      def git_submodule_update
        `git submodule update`
      end

      def git_rev_parse(repothing)
        `git rev-parse #{repothing}`
      end

      def git_cat_file(object)
        `git cat-file -p #{object} 2> /dev/null`
      end
    end
  end
end

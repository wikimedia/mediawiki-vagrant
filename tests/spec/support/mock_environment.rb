module MediaWikiVagrant
  module SpecHelpers
    module MockEnvironment
      def mock_directory(path)
        raise 'you must explicitly enable fakefs before mocking files' unless FakeFS.activated?

        FakeFS::FileUtils.mkdir_p(path)
      end

      def mock_empty_files_in(dir, *paths)
        mock_files_in(dir, paths.each.with_object({}) { |path, hash| hash[path] = '' })
      end

      def mock_file(path, content: "\n", mtime: nil)
        raise 'you must explicitly enable fakefs before mocking files' unless FakeFS.activated?

        mock_directory(File.dirname(path))
        FakeFS::File.write(path, content)
        FakeFS::File.utime(mtime, mtime, path) unless mtime.nil?
      end

      def mock_files(paths_and_content = {})
        paths_and_content.each { |path, content| mock_file(path, content: content) }
      end

      def mock_files_in(dir, paths_and_content = {})
        dir = Pathname.new(dir)

        paths_and_content.each { |path, content| mock_file(dir.join(path), content: content) }
      end
    end
  end
end

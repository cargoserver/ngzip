module CoreExtensions
  module String
    module EscapeGlob
      # Ref: https://stackoverflow.com/questions/14127343/why-dir-glob-in-ruby-doesnt-see-files-in-folders-named-with-square-brackets
      # Ref: https://bugs.ruby-lang.org/issues/8258
      def escape_glob
        self.gsub(/[\\\{\}\[\]\*\?]/) { |x| "\\" + x }
      end
    end
  end
end

module Wright
  class Foo
    class Bar
      # nested class, loaded on demand
      class Baz
        def was_loaded
          true
        end
      end
    end
  end
end

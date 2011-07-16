# NEXTGEN CONSIDERATIONS

## 2011-07-16 | Ok/No Style Testing

Currently we have something like this:

```ruby
  TestCase HelloWorld do
    unit :hello => "aspect" do
      ...
    end
  end
```

To move Lemon in the direction of KO's design we need to 
convert that to:

```ruby
  TestCase HelloWorld do
    unit :hello do
       test "aspect" do
         ...
       end
    end
  end
```

But we have some issues. Currently we can create a "setup" and 
the return value of the setup procedure is passed to the unit test.

```ruby
  TestCase HelloWorld do
    setup do
      HelloWorld.new
    end

    unit :hello => "aspect" do |hello_world|
      ...
    end
  end
```

But the new form of `#test` method can use ok/no checks.

```ruby
  TestCase HelloWorld do
    unit :hello
      test "aspect" do |arg|
        ...
      end

      ok "arg"
      no "arg"
    end
  end
```

It's fine if the setup instance is passed to #unit, e.g.

```ruby
  TestCase HelloWorld do
    setup do
      HelloWorld.new
    end

    unit :hello do |hello_world|
      test "aspect" do |arg|
        ...
      end

      ok "arg"
      no "arg"
    end
  end
```

But setup makes more sense being passed to the test b/c otherwise a new
unit has to be defined for each new #setup, which defeats part of the purpose
of the nex design. In that case they'd have to be combined.

```ruby
  TestCase HelloWorld do
    unit :hello do
      setup do
        HelloWorld.new
      end

      test "aspect" do  |hello_world, arg|
        ...
      end

      ok "arg"
      no "arg"
    end
  end
```

First off, it may be very tricky to implment this combination, as currently 
it depends on arity == 0 or not as to whether setup's return value is passed,
which would no longer work.

On second thought, the use of Ok/No style tests will often preclude
the use of setup return value b/c the arguments are likely to define 
a new instance of the target class. Would `#setup` also take `arg`?

```ruby
  TestCase HelloWorld do
    unit :hello do
      setup do |arg|
        HelloWorld.new
      end

      test "aspect" do  |hello_world, arg|
        ...
      end

      ok "arg"
      no "arg"
    end
  end
```

This is seeming rather whack-a-mole. Where is the simplification?
Perhaps that it is the key, that setup would take the arg and 
pass any needed args on the the test method.

```ruby
  TestCase HelloWorld do
    unit :hello do
      setup "..." do |arg1, arg2|
        HelloWorld.new(arg1), arg2
      end

      test "aspect" do  |hello_world, arg2|
        ...
      end

      ok "arg"
      no "arg"
    end
  end
```

If there is no setup method, then the args are passed directly
to the test procedure.

It does seem a bit strange, granted, but it the correct model.

Now in contrast to other test systems, it might be argued that 
a setup procedure belongs to a _context_ and that a context 
should only have one such possible procedure --unlike Lemons
model which can redefine the setup procedure as it goes along.
If we were to take that into consideration we would have...

```ruby
  TestCase HelloWorld do
    unit :hello do
      context "..." do
        setup do |arg1, arg2|
          HelloWorld.new(arg1), arg2
        end

        test "aspect" do  |hello_world, arg2|
          ...
        end

        ok "arg"
        no "arg"
      end
    end
  end
```

But the `unit` already setsup a context and I am not sure
adding an additional layer buys us anything by an an empty
instance space.

Also, why no just add ok/no checks to the current design?

```ruby
  TestCase HelloWorld do
    unit :hello => "aspect" do |arg|
      ...
    end

    ok "arg"
    no "arg"
  end
```


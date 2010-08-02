2010-08-02 | Enforcing the Unit

The current API for creating a Lemon unit testcase looks like this:

    covers 'someclass'

    testcase SomeClass do

      unit :some_method => "does something or another" do
        # ...
      end

    end

As it currentlt standa the current design is little more than a means of
organization, orienting the developer to think in terms of test units.
What is does not do is enforce the actual testing the the unit referenced.
We could put any old mess in the unit block and as long as it did not raise
an exception, it would get a *pass*.

Taking some time to consider this in depth, I've concieved of a way in which
that use of the method could in fact be enforced.

    covers 'someclass'

    testcase SomeClass do

      setup do
        SomeClass.new
      end

      unit :some_method => "does something or another" do |unit|
        unit.object      # object from setup
        unit.call(...)   # calls #some_method on unit.object
      end

    end

What is intersting about this, beyond that fact that it enforces the use of
the class or module and method involved, but that it also does so in
a way naturally suited to mocking --the `unit` delegator could even have
mocking methods built-in.

      unit :some_method => "does something or another" do |unit|
        unit.receives.foo(:bar)  # object from setup would receive this call
        unit.returns(:baz)       # the subsequent #call will return this
        unit.call(...)           # calls #some_method on unit.object
      end

On the downside this approach limits what can be done in the unit block.
One _has_ to utilize the object as defined in `setup` and one _has_ to invoke
the unit method via the `#call` interface. Though, I suppose one could argue
that these limitations are a good thing, as they help the unit stay narrowly
focused on that goal at hand.

I think this approach is worth considering for a possible furture version.
Perhaps a "Lemon 2.0". For the time being I believe we can enforce the unit
without resorting this major API change.

The next release of Lemon will temporarily override the unit method on the
target class for each unit execution. If the unit method gets called within
the unit block, then it will be noted by the overridden method before passing
off to the original definition. The approach is perhaps a bit draconian, and 
is certainly only possible thanks to the remarkable dynamicism of Ruby, but
it should work perfectly well. So now, if the target method is not called within
the taget block, the unit will raise a Pending exception, regardless of the 
code in the block. Unit Enforced!


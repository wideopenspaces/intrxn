# intrxn

![Ruby](https://github.com/wideopenspaces/intrxn/workflows/Ruby/badge.svg?branch=master)

**intrxn** is a concise library for encapsulating complex sequential interactions into workflows. 

It supplies some basic validations and error-checking and then tries to stay out of your way!

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'intrxn', git: 'https://github.com/wideopenspaces/intrxn'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install intrxn

## Usage

The core of **intrxn** is the `Workflow` - a class that describes a set of 
sequential interactions to be performed on a given `context`:

```ruby
class AssembleWidget < Intrxn::Workflow
  # the interactions DSL allows you to specify a list
  # of interactions that will act upon the @context
  # in this workflow.
  #
  # The `prefix` keyword is useful for specifying a separate 
  # directory/module to hold your interactions.  
  interactions :gather_supplies,
               :connect_foo_to_bar,
               :confabulate_mandibulary_ventricles,
               :insert_neutron_batteries,
               :assemble_radiative_shielding,
               :add_branding,
               :wrap_in_unbreakable_plastic,
               prefix: :'widgets/interactions'

  # Optional - only specify this method if you intend to override it.
  # Default behavior is below: your context is a Hash supplied to the keyword
  # argument ':context' 
  def initialize(context: {})
    @context = context
  end 
  
  # This method can be whatever you want to call it; it's simply the method you'll use to run
  # the workflow. (e.g., `AssembleWidget.new(context: {...}).process!`) 
  # 
  # This can be omitted. By default it returns the entire context. If you want to return
  # only a portion of the context, override this method. 
  def process! 
    @context = perform
  end
end

class ConnectFooToBar < Intrxn::Interaction
  # Tell Intrxn that this interaction requires the presence
  # of `foo` and `bar` keys in `context`, but that
  # those keys can have values of `nil`
  #
  # (Omit `allow_nil` to require values for the required keys) 
  needs :foo, :bar, allow_nil: true

  # Add a method to verify something about `foo` when `verifications_pass?` is called.
  # Target method must return either true or false.
  verifies :foo, with: :compatible_foo?
 
  # Tell Intrxn that this interaction will provide `widget`, `foo` & `bar` to the 
  # returned context. If removing `foo` or `bar` from the context, omit them
  # from the promises line. 
  #
  # Future versions of this gem may add the ability to ensure
  # the needs & promises of sequential interactions are compatible. 
  promises :widget, :foo, :bar

  # Add a method to confirm `widget`
  confirms :widget, with: :meets_minimum_safety_standards?
  
  # Sets up the `#process!` method used by the Workflow internally,
  # and enables the check for promised values.
  #
  # You can alternately define the `#process!` method yourself, but be
  # sure to call `super` at the end if you wish to ensure promised values.
  process do
    # In this example we want to raise an error if the context's contents
    # do not pass validation 
    raise StandardError unless verifications_pass?

    # Do your application-specific work here
    # ...  
    
    # Call `confirm_state_of_targets!` to raise an error if targets
    # don't pass confirmation checks
    confirm_state_of_targets!(context)
  end
  
  private

  # A great place to store your own methods
end
``` 

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` 
to run the tests. You can also run `bin/console` for an interactive prompt that will allow 
you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. 

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/wideopenspaces/intrxn. 
This project is intended to be a safe, welcoming space for collaboration, and contributors are 
expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## Code of Conduct

Everyone interacting in the Intrxn project’s codebases, issue trackers, chat rooms and mailing 
lists is expected to follow the 
[code of conduct](https://github.com/wideopenspaces/intrxn/blob/master/CODE_OF_CONDUCT.md).

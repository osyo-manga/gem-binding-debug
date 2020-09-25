# Binding::Debug

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/binding/debug`. To experiment with that code, run `bin/console` for an interactive prompt.

TODO: Delete this and the text above, and describe your gem

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'binding-debug'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install binding-debug

## Usage

```ruby
require "binding/debug"

using BindingDebug

def plus a, b
  a + b
end

#######################################
## local variable output
#######################################

hoge = 42
p binding.debug "hoge"
# => "hoge # => 42"
p binding.debug %{ hoge }

binding.p "hoge"
# => "hoge # => 42"

binding.puts "hoge"
# output: "hoge # => 42"

# with format
p binding.debug("hoge"){ |name, value| "#{name} - #{value}" }
# => "hoge - 42"


#######################################
## call method
#######################################

binding.p "plus(1, 2)"
# => "plus 1, 2 # => 3"


#######################################
## call variable and methods
#######################################

foo = "homu"
binding.puts %{
  foo.to_s.upcase
  plus 1, 2
  (0..20).to_a
  foo.class.name
}
# output:
# foo.to_s.upcase # => HOMU
# plus 1, 2 # => 3
# (0..20).to_a # => [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20]
# foo.class.name # => String
```

### `puts` with blocks

```ruby
require "binding/debug"

using BindingDebug

def plus a, b
  a + b
end

foo = "homu"

# puts with blocks
puts {
  foo.to_s.upcase
  plus 1, 2
  (0..20).to_a
  foo.class.name
}
# output:
# foo.to_s.upcase # => HOMU
# plus 1, 2 # => 3
# (0..20).to_a # => [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20]
# foo.class.name # => String
```

Supported `Kernel.#p` , `Kernel.#pp`.


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/osyo-manga/gem-binding-debug.


## Release Note

#### 0.2.0

* Add `BindingDebug::Formats`
* Add `Binding#pp`
* Add with block in `Kernle.#puts` `Kernle.#p` `Kernle.#pp` 
  * e.g `puts { value } # => "value # => #{value}"`
* Change default format `expr : result` to `expr # => result`

#### 0.1.0

* Release!!



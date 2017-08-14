# NestedStringParser

`NestedStringParser` takes a multi-line string, containing indented lines, and returns a `Node` object for each line, such that:

* `node.parent` returns the node for the most recent less-indented previous line
* `node.children` returns the nodes for all following more-indented lines, either up to end-of-string, or up to the next equally-indented or less-indented line
* `node.value` returns the stripped text of the line
* `node.indent` returns the length of the blank string for this line in the source string

See specs for some examples.

`NestedStringParser` is not terribly fussy about indentation ; any string that is indented more than a previous string will be assigned the previous string as parent. Use `format` to normalise indentation if your input is sloppy. Specs provide an example of sloppy indentation.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'nested_string_parser'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install nested_string_parser


## Contributing

1. Fork it ( https://github.com/[my-github-username]/nested_string_parser/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

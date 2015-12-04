# human-name-rb
Ruby bindings for the Rust crate [`human_name`](https://github.com/djudd/human-name), a library for parsing and comparing human names.

See the [`human_name` docs](djudd.github.io/human-name) for details.

# Examples

```ruby
  require 'humanname'

  doe_jane = HumanName.parse("Doe, Jane")
  doe_jane.surname
  => "Doe"
  doe_jane.given_name
  => "Jane"
  doe_jane.initials
  => "J"

  j_doe = HumanName.parse("J. Doe")
  j_doe.surname
  => "Doe"
  j_doe.given_name
  => nil
  j_doe.initials
  => "J"

  j_doe == doe_jane
  => true
  j_doe == HumanName.parse("John Doe")
  => true
  doe_jane == HumanName.parse("John Doe")
  => false
```

# Supported environments

Without modification, 64-bit Linux. Depends on a `.so` dynamic library built on
Travis' container  infrastructure, which means Ubuntu 12.04.

In theory, anywhere where the nightly Rust compiler will run:

1. Build your own `libhuman_name.so` (or `libhuman_name.dylib` on OS X):
```bash
curl -s https://static.rust-lang.org/rustup.sh | sh -s -- --channel=nightly
git clone git@github.com:djudd/human-name.git
cd human-name
cargo build --release
```

2. Fork this `djudd/human-name.rb`, replace `libhuman_name.so` with the file
from `human-name/target/release`, and run `bundle exec rake` to ensure the
specs are passing.

Depends on the `ffi` gem.

# Benchmark results

Comparing to [`people`](https://github.com/academia-edu/people), [`namae`](https://github.com/berkmancenter/namae), and [`human_name_parser`](https://github.com/abachman/human_name_parser),
on 16k real examples taken mostly from PubMed author fields.

```
$ bundle exec rake benchmark
people gem:
  2.280000   0.010000   2.290000 (  2.313764)
namae gem:
  2.710000   0.020000   2.730000 (  2.745188)
human_name_parser gem:
  1.640000   0.010000   1.650000 (  1.659007)
this gem:
  0.320000   0.030000   0.350000 (  0.349284)
```

Our implementation uses a similar strategy to `people` and `human_name_parser`
but covers significantly more edge cases, and also supports comparison.
(`human_name_parser` also covers fewer edge cases than `people`, as of writing,
which probably explains its speed advantage.)

`namae` uses a formal grammar, and so probably captures some cases this gem
does not, although it certainly also misses some which this gem captures.

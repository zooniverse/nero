[![Build Status](https://travis-ci.org/zooniverse/retirement_swap.svg)](https://travis-ci.org/zooniverse/retirement_swap)

# RetirementSwap

This runs as a service listening to the Kafka event stream coming out of Panoptes,
determines when a subject needs to retired, in which case it calls back to Panoptes' API to mark it as retired.


### Development

The entire test suite finishes really fast. Just rerun it every time you make a change:

```
bundle exec rerun -x bin/rspec
```

Running the actual thing:

```
cat example_input.json | ruby -Ilib bin/cli_pipeline
```

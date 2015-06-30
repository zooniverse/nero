[![Build Status](https://travis-ci.org/zooniverse/retirement_swap.svg)](https://travis-ci.org/zooniverse/retirement_swap)

# RetirementSwap

This runs as a service listening to the Kafka event stream coming out of Panoptes,
determines when a subject needs to retired, in which case it calls back to Panoptes' API to mark it as retired.

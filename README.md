# async-pool
asynchronous resource pool using bluebird

## Installation

    npm install git+https://git@github.com/shaunc/async-pool.git
  
## Usage

    AsyncPool = require 'async-pool'
    Promise = require 'bluebird'
  
    pool = new AsyncPool(['foo', 'bar', 'baz'])
  
    Promise.map [1..8], (i)->
      Promise.using pool.use(), (s)->
        console.log(s, pool.resources.length, pool.waiting.length)
        if i % 2 == 0
          throw new Error("Even numbers are bad luck.")
      .catch (err)->
      
Produces:

    baz 0 5
    bar 0 5
    foo 0 5
    baz 0 2
    bar 0 2
    foo 0 2
    baz 1 0
    bar 1 0
      

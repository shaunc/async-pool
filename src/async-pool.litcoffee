Async Pool
==========

Object that manages a pool of resources, leting resource
users use and then return them so that no resource is used
by more than one user at the same time.

    Promise = require 'bluebird'

    class AsyncPool

Build a pool. Resources should be an array of resources.

      constructor: (resources)->
        @resources = resources
        @waiting = []

Get a resource when one comes available. Use with `Promise.using`

Throws a syncrhonous error if there is no pool.

      use: ()->
        self = this
        if !@resources?
          throw new Error('AsyncPool is closed.')
        return new Promise( (res)->
          resource = self.resources.pop()
          if resource?
            return res(resource)
          self.waiting.push(res)
        ).disposer (resource)->
          waiter = self.waiting.pop()
          console.log('-- client returned; waiter', waiter?.name ? waiter )
          if waiter?
            waiter(resource)
          else
            self.resources.push resource

Stop managing pool. Calls to `use` after `stop` trigger an exception.

      close: ()->
        @resources = null


    module.exports = AsyncPool
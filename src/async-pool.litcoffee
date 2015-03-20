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

      use: ()->
        self = this
        return new Promise( (res)->
          resource = self.resources.pop()
          if resource?
            return res(resource)
          self.waiting.push(res)
        ).disposer (resource)->
          waiter = self.waiting.pop()
          if waiter?
            waiter(resource)
          else
            self.resources.push resource

    module.exports = AsyncPool
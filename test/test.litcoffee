Test AsyncPool

    require 'mocha'
    should = (require 'chai').should()
    Promise = require 'bluebird'
    AsyncPool = require '../index.js'

    describe 'AsyncPool', ->

      it 'throws an error if asked for resource from non-existent pool', ->
        pool = new AsyncPool()
        should.throw ->
          Promise.using pool.use()
        , 'AsyncPool is closed or without resources.'

      it 'throws an error if asked for resource from an empty pool', ->
        pool = new AsyncPool([])
        should.throw ->
          Promise.using pool.use()
        , 'AsyncPool is closed or without resources.'

      it 'serializes access to resources', ->
        pool = new AsyncPool([1,2])
        Promise.map [1,2,3,4,5], (i)->
          Promise.using pool.use(), (j)->
            return [i, j]
        .then (results)->
          results.sort()
          results.should.eql [
            [1,2], [2,1], [3,2], [4, 1], [5, 2]]

      describe 'can be closed:', ->
        pool = null
        beforeEach ->
          pool = new AsyncPool([1, 2])

        it 'reports not closed if not closed.', ->
          pool.isClosed().should.equal no

        it 'reports closed if closed immediately', ->
          pool.closeImmediately()
          pool.isClosed().should.equal yes

        it 'throws error if used after immediate close', ->
          pool.closeImmediately()
          should.throw ->
            pool.use()
          , 'AsyncPool is closed or without resources.'

        it 'throws on closing immediately with resources checked out', ->
          Promise.using pool.use(), ->
            should.throw ->
              pool.closeImmediately()
            , 'AsyncPool closing while resources still checked out.'

        it 'close with no resources checked out closes synchronously', ->
          pool.close().should.equal yes
          pool.isClosed().should.equal yes
          should.not.exist pool.willClose

        it 'close and wait with nothing checked out resolves synchronously', ->
          closePromise = pool.closeAndWait()
          closePromise.isPending().should.equal no
          pool.isClosed().should.equal yes
          closePromise.value().should.equal pool

        it 'throws an error if closed with no checkouts then used', ->
          pool.close()
          should.throw ->
            pool.use()
          , 'AsyncPool is closed or without resources.'

        it "closes but doesn't cause error if resources checked out", ->
          Promise.using pool.use(), ->
            pool.close()
            pool.isClosed().should.equal yes
            pool.willClose.should.equal yes
          .then (pool_)->
            pool.should.equal pool
            pool.isClosed().should.equal yes

        it 'throws an error if used while waiting to close', ->
          Promise.using pool.use(), ->
            pool.close()
            should.throw ->
              Promise.using pool.use(), ->
            , 'AsyncPool is closed or without resources.'

        it 'allows two closes', ->
          pool.close()
          pool.close()
          pool.isClosed().should.equal yes

        it 'allows two close and waits; both resolve', ->
          Promise.join(
            pool.closeAndWait(),
            pool.closeAndWait())
          .spread (c1, c2)->
            c1.should.equal pool
            c1.should.equal pool
            pool.isClosed().should.equal yes




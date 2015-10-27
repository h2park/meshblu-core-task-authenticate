AuthenticateTask = require '../../src/authenticate-task'

describe 'AuthenticateTask', ->
  describe '->run', ->
    beforeEach ->
      @authDevice = sinon.stub()
      dependencies =
        authDevice: @authDevice
      @sut = new AuthenticateTask dependencies

    describe 'when called with a valid request and callback', ->
      beforeEach (done) ->
        @authDevice.yields null
        metadata = uuid: 'super-uuid', token: 'awesome-token'
        request = metadata: metadata, rawData: '{}'
        @sut.run request, (@error, @response) => done()

      it 'should not have an error', ->
        expect(@error).to.not.exist

      it 'should respond with 200 status metadata', ->
        metadata = uuid: 'super-uuid', token: 'awesome-token', code: 200, status: "OK"
        expect(@response.metadata).to.deep.equal metadata

      it 'should respond with the correct rawData', ->
        expect(@response.rawData).to.equal '{"authenticated":true}'

    describe 'when called with a different valid request and callback', ->
      beforeEach (done) ->
        @authDevice.yields null
        metadata = uuid: 'cool-uuid', token: 'great-token'
        request = metadata: metadata, rawData: '{}'
        @sut.run request, (@error, @response) => done()

      it 'should not have an error', ->
        expect(@error).to.not.exist

      it 'should respond with 200 status metadata', ->
        metadata = uuid: 'cool-uuid', token: 'great-token', code: 200, status: "OK"
        expect(@response.metadata).to.deep.equal metadata

      it 'should respond with the correct rawData', ->
        expect(@response.rawData).to.equal '{"authenticated":true}'

    describe 'when called with invalid credentials in the reqeust', ->
      beforeEach (done) ->
        @authDevice.yields new Error("invalid device")
        metadata = uuid: 'wack-uuid', token: 'super-wack-token'
        request = metadata: metadata, rawData: '{}'
        @sut.run request, (@error, @response) => done()

      it 'should not have an error', ->
        expect(@error).to.not.exist

      it 'should respond with 401 status metadata', ->
        metadata = uuid: 'wack-uuid', token: 'super-wack-token', code: 401, status: "invalid device"
        expect(@response.metadata).to.deep.equal metadata

      it 'should respond with the correct rawData', ->
        expect(@response.rawData).to.equal '{"authenticated":false}'

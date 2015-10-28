AuthenticateTask = require '../../src/authenticate-task'

describe 'AuthenticateTask', ->
  describe '->run', ->
    beforeEach ->
      @device = verifyToken: sinon.stub()
      @Device = sinon.spy => @device
      dependencies =
        Device: @Device
      @sut = new AuthenticateTask dependencies

    describe 'when called with a valid request and callback', ->
      beforeEach (done) ->
        @device.verifyToken.yields null, true

        request =
          metadata:
            auth:
              uuid: 'super-uuid'
              token: 'awesome-token'
            responseId: 'truck'
          rawData: 'null'

        @sut.run request, (@error, @response) => done()

      it 'should instantiate a Device with the uuid', ->
        expect(@Device).to.have.been.calledWithNew
        expect(@Device).to.have.been.calledWith uuid: 'super-uuid'

      it 'should call verifyToken with the token', ->
        expect(@device.verifyToken).to.have.been.calledWith 'awesome-token'

      it 'should not have an error', ->
        expect(@error).to.not.exist

      it 'should respond with 200 status metadata', ->
        expectedMetadata =
          responseId: 'truck'
          code: 200
          status: "OK"

        expect(@response.metadata).to.deep.equal expectedMetadata

      it 'should respond with the correct rawData', ->
        expect(@response.data).to.deep.equal authenticated: true

    describe 'when called with invalid credentials in the request', ->
      beforeEach (done) ->
        @device.verifyToken.yields null, false

        request =
          metadata:
            auth:
              uuid: 'wack-uuid'
              token: 'super-wack-token'
            responseId: 'soup-too-hot'
          rawData: 'null'

        @sut.run request, (@error, @response) => done()

      it 'should not have an error', ->
        expect(@error).to.not.exist

      it 'should respond with 403 status metadata', ->
        requestMetadata =
          responseId: 'soup-too-hot'
          code: 403
          status: "Forbidden"

        expect(@response.metadata).to.deep.equal requestMetadata

      it 'should respond with the correct rawData', ->
        expect(@response.data).to.deep.equal authenticated: false

    describe 'when verifyToken explodes spectacularly', ->
      beforeEach (done) ->
        errorMessage = 'Lead: If I am not supposed to eat them, why are they called paint "CHIPS"?'
        @device.verifyToken.yields new Error(errorMessage)

        request =
          metadata:
            auth:
              uuid: 'wack-uuid'
              token: 'super-wack-token'
            responseId: 'soup-too-hot'
          rawData: 'null'

        @sut.run request, (@error, @response) => done()

      it 'should not have an error', ->
        expect(@error).to.not.exist

      it 'should respond with 500 status metadata', ->
        requestMetadata =
          responseId: 'soup-too-hot'
          code: 500
          status: "Internal Server Error"

        expect(@response.metadata).to.deep.equal requestMetadata

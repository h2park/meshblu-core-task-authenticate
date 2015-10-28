http = require 'http'

class AuthenticateTask
  constructor: (dependencies={}) ->
    {@Device} = dependencies
    @Device ?= require 'meshblu-server/lib/models/device'

  run: (request, callback=->) =>
    {metadata} = request
    {uuid, token} = metadata.auth

    device = new @Device uuid: uuid
    device.verifyToken token, (error, authenticated) =>
      code = 200
      code = 403 unless authenticated
      code = 500 if error?
      status = http.STATUS_CODES[code]

      response =
        metadata:
          responseId: metadata.responseId
          code: code
          status: status
        data:
          authenticated: authenticated

      callback null, response

module.exports = AuthenticateTask

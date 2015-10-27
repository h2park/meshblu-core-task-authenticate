
class AuthenticateTask
  constructor: (dependencies={}) ->
    @authDevice = dependencies.authDevice ? require 'meshblu-server/lib/authDevice'

  run: (request, callback=->) =>
    {metadata} = request
    {uuid, token} = metadata

    authenticated = "true"
    metadata.code = 200
    metadata.status = "OK"

    @authDevice uuid, token, (error) =>
      if error?
        authenticated = "false"
        metadata.code = 401
        metadata.status = error?.message ? error
      callback null, metadata: metadata, rawData: "{\"authenticated\":#{authenticated}}"

module.exports = AuthenticateTask

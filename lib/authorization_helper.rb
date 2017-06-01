module AuthorizationHelper
  def authorize_github(request)
    # compare X-Hub-Signature HMAC
    algorithm, challenge = request.env["HTTP_X_HUB_SIGNATURE"].split("=")
    halt 403 if !algorithm || !challenge

    key = ENV["GITHUB_WEBHOOK_TOKEN"]
    body = request.body.read; request.body.rewind
    hmac = hmac_hex_digest(algorithm, key, body)
    halt 403 if hmac != challenge
  end

  def hmac_hex_digest(algorithm, key, body)
    digest = OpenSSL::Digest.new(algorithm)
    OpenSSL::HMAC.hexdigest(digest, key, body)
  end
end

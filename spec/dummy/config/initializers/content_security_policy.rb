if Gem.loaded_specs['rails'].version >= Gem::Version.new('5.2.0')
  Rails.application.config.content_security_policy do |policy|
    # Empty. Only need one endpoint (/strict_csp) to use a strict CSP in our tests.
  end

  Rails.application.config.content_security_policy_nonce_generator = -> request { SecureRandom.base64(16) }
end

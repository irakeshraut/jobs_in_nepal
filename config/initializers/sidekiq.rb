# frozen_string_literal: true

require 'active_support/security_utils'
require 'sidekiq'
require 'sidekiq/web'

Sidekiq::Web.use(Rack::Auth::Basic) do |user, password|
  # Protect against timing attacks:
  # - See https://codahale.com/a-lesson-in-timing-attacks/
  # - See https://thisdata.com/blog/timing-attacks-against-string-comparison/
  # - Use & (do not use &&) so that it doesn't short circuit.
  # - Use digests to stop length information leaking
  ActiveSupport::SecurityUtils.secure_compare(user, ENV.fetch('SIDEKIQ_USER', nil)) &
    ActiveSupport::SecurityUtils.secure_compare(password, ENV.fetch('SIDEKIQ_PASSWORD', nil))
end

require 'webmock/rspec'

WebMock.disable_net_connect!(
  allow_localhost: true,
  allow: [/^http:\/\/127\.0\.0\.1/],
)

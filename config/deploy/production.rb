set :branch, 'production'
set :rails_env, :production

server '13.57.192.112', user: 'shopify', roles: %w{app db web}

set :branch, 'production'
set :rails_env, :staging

server '13.57.234.13', user: 'shopify', roles: %w{app db web}

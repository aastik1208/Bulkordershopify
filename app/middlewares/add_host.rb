class AddHost
  def initialize(app)
    @app = app
  end

  def redirect(location)
    [301, {'Location' => location, 'Content-Type' => 'text/html'}, ['Moved Permanently']]
  end

  def csp(request)
    shop_url = "https://#{request.session[:shopify_domain]} " if request.session[:shopify_domain]
    "frame-ancestors #{shop_url}*.myshopify.com https://admin.shopify.com;"
  end

  def call(env)
    request = Rack::Request.new(env)
    request.session[:host] = request.params['host'] if request.params['host'].present?
    if request.params['host'].blank? && request.session[:host].present? && request.request_method == "GET"
      param = request.url.include?("?") ? "&host=#{request.session[:host]}" : "?host=#{request.session[:host]}"
      url = request.url + param
      return redirect(url)
    end
    status, headers, response = @app.call(env)
    headers['Content-Security-Policy'] = csp(request)
    [status, headers, response]
  end
end

class StoreFront::BaseController < ActionController::Base
  
  include ShopifyApp::AppProxyVerification

  def render_404
    render file: Rails.root.join('public', '404.html'), status: 404 and return
  end

  def render_422
    render file: Rails.root.join('public', '422.html'), status: 422 and return
  end
end

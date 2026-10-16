class ApplicationMailer < ActionMailer::Base
  default from: Rails.application.secrets.shop_sender_email

  layout 'mailer'
end

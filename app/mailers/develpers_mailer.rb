class DevelopersMailers < ApplicationMailer
  default to: Rails.application.secrets.developer_email

  def customer_redaction_failure_email(customer_email)
    @customer_email = customer_email
    mail(subject: default_i18n_subject)
  end
end

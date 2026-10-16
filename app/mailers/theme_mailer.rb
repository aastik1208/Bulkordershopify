class ThemeMailer < ApplicationMailer

  def theme_already_modified_email(shop_id)
    send_mail(shop_id)
  end

  def theme_modification_success_email(shop_id)
    send_mail(shop_id)
  end

  def theme_modification_failure_email(shop_id)
    send_mail(shop_id)
  end

  private

    def send_mail(shop_id)
      @shop = Shop.find_by(id: shop_id)
      if @shop.present?
        @shop_owner = @shop.shopify_owner
        mail(to: @shop.shopify_email, subject: default_i18n_subject(shop_domain: @shop.shopify_domain))
      end
    end
end

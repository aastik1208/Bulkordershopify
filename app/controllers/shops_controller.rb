class ShopsController < ApplicationController

  def update_contact_emails
    current_shop.update(shop_params)
  end

  private

    def shop_params
      params.require(:shop).permit(:contact_emails)
    end
end

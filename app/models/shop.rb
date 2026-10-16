class Shop < ApplicationRecord

  ## CONSTANTS
  SHOPIFY_PRODUCT_BULK_ORDER_PATH = 'sections/product-bulk-order.liquid'
  APP_PRODUCT_BULK_ORDER_SECTION_FILE_PATH = Rails.root.join('lib', 'theme_modifications', 'product-bulk-order.liquid')
  THEME_MODIFICATION_REMOVAL_INSTRUCTION_FILE_PATH = Rails.root.join('lib', 'theme_modifications', 'removal_instructions.txt')

  ## MODULES
  include ShopifyApp::ShopSessionStorage

  ## ASSOCATIONS
  has_many :order_uploads, dependent: :destroy
  has_many :store_front_order_uploads, -> { where(source: :store_front) }, class_name: 'OrderUpload'
  has_many :products, dependent: :destroy, autosave: true
  accepts_nested_attributes_for :products, allow_destroy: true

  ## CALLBACKS
  after_commit :add_shopify_details, on: :create


  def enqueue_modify_theme_job
    ModifyThemeJob.perform_later(id)
  end

  def api_version
    ShopifyApp.configuration.api_version
  end

  def modify_theme
    unless theme_already_modified?
      create_product_bulk_order_section
    else
      send_theme_already_modifed_email
    end
  end

  def update_shopify_details(updated_data)
    update_shopify_email(updated_data[:email])
    update_shopify_owner(updated_data[:shop_owner])
    self.save
  end

  private

    def update_shopify_email(new_shopify_email)
      if shopify_email != new_shopify_email
        self.shopify_email = new_shopify_email
      end
    end

    def update_shopify_owner(new_shopify_owner)
      if shopify_owner != new_shopify_owner
        self.shopify_owner = new_shopify_owner
      end
    end

    def add_shopify_details
      with_shopify_session do
        shop = ShopifyAPI::Shop.current
        update_columns(shopify_email: shop.email, shopify_owner: shop.shop_owner)
      end
      Product.fetch_all_shopify_products(self)
    end

    def theme_already_modified?
      begin
        with_shopify_session do |variable|
          ShopifyAPI::Asset.find(SHOPIFY_PRODUCT_BULK_ORDER_PATH)
        end
        true
      rescue ActiveResource::ResourceNotFound => exception
        false
      end
    end

    def create_product_bulk_order_section
      asset_value = get_product_bulk_order_value
      begin
        with_shopify_session do
          ShopifyAPI::Asset.create(key: SHOPIFY_PRODUCT_BULK_ORDER_PATH, value: asset_value)
        end
        send_theme_modification_success_email
      rescue Exception => exception
        Bugsnag.notify(exception)
        send_theme_modification_failure_email
      end
    end

    def get_product_bulk_order_value
      data = File.read(APP_PRODUCT_BULK_ORDER_SECTION_FILE_PATH)
    end

    def send_theme_already_modifed_email
      ThemeMailer.theme_already_modified_email(id).deliver_later
    end

    def send_theme_modification_success_email
      ThemeMailer.theme_modification_success_email(id).deliver_later
    end

    def send_theme_modification_failure_email
      ThemeMailer.theme_modification_failure_email(id).deliver_later
      ApiFailureMailer.shop_theme_modification_failure_email(id).deliver_later
    end

end

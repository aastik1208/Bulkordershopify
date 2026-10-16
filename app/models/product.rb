class Product < ApplicationRecord

  ## CONSTANTS
  BULK_ORDER_METAFIELD_NAMESPACE = 'bulk_order'
  BULK_ORDER_FORM_METAFIELD_KEY = 'allowed'

  ## ASSOCIATIONS
  belongs_to :shop
  has_many :variants, dependent: :destroy, autosave: true

  ## VALIDATIONS
  validates :shopify_id, presence: true
  validates :store_front_form, inclusion: [false, true], allow_blank: true

  ## CALLBACKS
  # after_commit :enqueue_fetch_shopify_title_job, on: :create, unless: :shopify_title
  after_commit :enqueue_add_metafield_job, on: :update
  after_commit :enqueue_delete_metafield_job, on: :update

  accepts_nested_attributes_for :variants
  ## CLASS METHODS
  def self.fetch_all_shopify_products(shop)
    begin
      shop.with_shopify_session do
        shopify_products = ShopifyAPI::Product.find(:all, params: {limit: 100})
        all_shopify_products = shopify_products
        while shopify_products.next_page?
          shopify_products = shopify_products.fetch_next_page
          all_shopify_products += shopify_products
        end

        all_shopify_products.each do |shopify_product|
          product = shop.products.find_by(shopify_id: shopify_product.attributes['id'])
          if product.present?
            product.update_products_data(shopify_product.attributes, shop)
          else
            build_product(shopify_product.attributes, shop)
          end
        end

        ## saving all build/updated products
        shop.save
      end
    rescue Exception => exception
      p exception.message
      Bugsnag.notify(exception)
    end
  end

  def self.get_required_attrs_from(attrs, shop, with_shopify_id=false)
    attrs = JSON.parse(attrs.to_json, object_class: OpenStruct)
    product_hash = {
              shopify_title: attrs.title,
              variants_attributes: attrs.variants.map{ |v|
                {
                  shopify_id: v.id,
                  shopify_title: v.title,
                }
              },
              shop_id: shop.id
            }
    product_hash.merge!({shopify_id: attrs.id}) if with_shopify_id
    product_hash
  end

  def self.build_product(product_attrs, shop)
    shop.products.build(get_required_attrs_from(product_attrs, shop, true))
  end

  def self.create_new_shopify_product(webhook, shop)
    shop.products.create!(get_required_attrs_from(webhook, shop, true))
  end

  ## INSTANCE METHODS
  def update_products_data(webhook, shop)
    product_hash = self.class.get_required_attrs_from(webhook, shop)
    product_hash[:variants_attributes].each { |variant| variant[:id] = variants.detect{ |v| v.shopify_id == variant[:shopify_id]}.try(:id) }
    variants.each do |variant|
      variant.mark_for_destruction unless product_hash[:variants_attributes].map{|attrs| attrs[:id]}.include?(variant.id)
    end
    self.update(product_hash)
  end


  # def fetch_shopify_title
  #   begin
  #     shop.with_shopify_session do
  #       shopify_product = ShopifyAPI::Product.find(shopify_id)
  #       update(shopify_title: shopify_product.title)
  #     end
  #   rescue Exception => exception
  #     Bugsnag.notify(exception)
  #     send_forms_product_selection_failure_email
  #   end
  # end

  def add_shopify_bulk_order_metafield
    begin
      shop.with_shopify_session do
        ShopifyAPI::Metafield.create(key: BULK_ORDER_FORM_METAFIELD_KEY, value: 'true', type: 'single_line_text_field', namespace: BULK_ORDER_METAFIELD_NAMESPACE, owner_id: shopify_id, owner_resource: 'product' )
      end
    rescue Exception => exception
      Bugsnag.notify(exception)
      send_forms_product_selection_failure_email
    end
  end

  private

    # def enqueue_fetch_shopify_title_job
    #   FetchShopifyProductTitleJob.perform_later(id)
    # end

    def enqueue_add_metafield_job
      if saved_change_to_attribute(:store_front_form) && store_front_form
        AddShopifyProductMetafieldJob.perform_later(id)
      end
    end

    def enqueue_delete_metafield_job
      if saved_change_to_attribute(:store_front_form) && !store_front_form
        DeleteShopifyProductMetafieldJob.perform_later(shop.shopify_domain, shopify_id)
      end
    end

    def send_forms_product_selection_failure_email
      ApiFailureMailer.forms_product_selection_failure_email(shop.id)
    end
end

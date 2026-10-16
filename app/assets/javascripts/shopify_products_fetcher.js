// function ShopifyProductsFetcher(options){
//   this.$selectBoxElement = options.$selectBoxElement;
//   this.$select2Container = this.$selectBoxElement.nextAll('span.select2-container')
//   this.fetchingLink = this.$selectBoxElement.data('fetching-link');
//   this.warningFlash = $("[data-flash='warning']");
// }

// ShopifyProductsFetcher.prototype.init = function(){
//   this.fetchShopifyProducts();
// };

// ShopifyProductsFetcher.prototype.fetchShopifyProducts = function(){
//   var _this = this;

//   $.getJSON(this.fetchingLink)

//     .done(function(json){
//       _this.appendOptionElements(json['options'], json['selected_values'])
//     })
//     .fail(function(xhr, status, error){
//       _this.showWarningFlash(xhr.responseJSON.error);
//     });
// };

// ShopifyProductsFetcher.prototype.appendOptionElements = function(options_hash, selected_values_array){
//   var allOptionElements = '';
//   $.each(options_hash, function(key, value){
//     if(!selected_values_array.includes(value))
//       allOptionElements += "<option value=" + value + ">" + key + "</option>";
//   });

//   this.$selectBoxElement.append(allOptionElements);
//   this.$selectBoxElement.select2({ theme: "bootstrap" });
// };

// ShopifyProductsFetcher.prototype.showWarningFlash = function(warning_message){
//   this.warningFlash.find('.body').text(warning_message);
//   this.warningFlash.removeClass('hide');
// }

// $(function(){
//   var shopifyProductsFetcherArguments = { $selectBoxElement : $("[data-fetch-shopify-products=true]")
//                                         },
//       shopifyProductsFetcher = new ShopifyProductsFetcher(shopifyProductsFetcherArguments);

//   shopifyProductsFetcher.init();
// });

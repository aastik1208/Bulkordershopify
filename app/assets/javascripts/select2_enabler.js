$(function(){

  // select tag on select product form
  $("[data-fetch-shopify-products=true]").select2({ theme: "bootstrap" });
  
  // select tag on filter form
  $("[data-filter-shopify-products=true]").select2({ theme: "bootstrap", width: '100%' });
});

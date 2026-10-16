
function SampleFileDownloadLinkEditor(options){
  this.$downloadLinkElement = options.$downloadLinkElement;
  this.$shopifyProductSelectElement = options.$shopifyProductSelectElement;
  this.$downloadFileInstructionElement = options.$downloadFileInstructionElement;
}

SampleFileDownloadLinkEditor.prototype.init = function(){
  this.$shopifyProductSelectElement.change(this.shopifyProductOnChangeHandler());
};

SampleFileDownloadLinkEditor.prototype.shopifyProductOnChangeHandler = function(){
  var _this = this;
  this.$downloadLinkElementParent = this.$downloadLinkElement.parent();

  return function(){
    if(this.value){
      _this.showDownloadLink(this);
      _this.editDownloadLink(this);
    } else{
      _this.showFileInstructionElement(this);      
    }
  }
};

SampleFileDownloadLinkEditor.prototype.showFileInstructionElement = function(){
  this.$downloadFileInstructionElement.removeClass('hide');
  this.$downloadLinkElementParent.addClass('hide');
}

SampleFileDownloadLinkEditor.prototype.showDownloadLink = function(_this){
  this.$downloadFileInstructionElement.addClass('hide');
  this.$downloadLinkElementParent.removeClass('hide');
}

SampleFileDownloadLinkEditor.prototype.editDownloadLink = function(_this){
  var new_value = this.$downloadLinkElement.attr('href').split('?')[0] + "?selected_shopify_product_id=" + _this.value;
  this.$downloadLinkElement.attr('href', new_value);
  this.$downloadLinkElement.text('Download sample file for ' + $(_this).find(":selected").text());
};


$(function(){
  var sampleFileDownloadLinkEditorArguments = { $downloadLinkElement : $("[data-order-sample-csv='true']"),
                                                $shopifyProductSelectElement : $("[data-selected-shopify-product='true']"),
                                                $downloadFileInstructionElement : $("[data-sample-file-download-instruction='yes']")
                                              },
      sampleFileDownloadLinkEditor = new SampleFileDownloadLinkEditor(sampleFileDownloadLinkEditorArguments);
      
  sampleFileDownloadLinkEditor.init();                         
});

function FilterFormEnabler(options){
  this.$filterFormElement = options.$filterFormElement;
  this.$submitButton = $(this.$filterFormElement.find(options.filterSubmitButtonSelector)[0]);
  this.$inputEmailElement = this.$filterFormElement.find(options.filterEmailFieldSelector);
  this.$inputProductElement = this.$filterFormElement.find(options.filterProductFieldSelector);
}

FilterFormEnabler.prototype.init = function(){
  this.enabler();
  this.$inputEmailElement.change(this.inputEmailElementOnChangeHandler());
  this.$inputProductElement.change(this.inputProductElementOnChangeHandler());
};

FilterFormEnabler.prototype.enabler = function(){
    if(this.$inputEmailElement.get()[0].value || this.$inputProductElement.get()[0].value)
      this.$submitButton.attr('disabled', false);
};

FilterFormEnabler.prototype.inputEmailElementOnChangeHandler = function(){
  var _this = this;

  return function(){
    if(this.value.trim().length){
      _this.$submitButton.attr('disabled', false);
    }
    else if(_this.$inputProductElement[0].value.length == 0){
      _this.$submitButton.attr('disabled', true);
    }
  }
};

FilterFormEnabler.prototype.inputProductElementOnChangeHandler = function(){
  var _this = this;

  return function(){
    if(this.value.length){
      _this.$submitButton.attr('disabled', false);
    }
    else if(_this.$inputEmailElement[0].value.trim().length == 0){
      _this.$submitButton.attr('disabled', true);
    }
  }
};

$(function(){
  var filterFormEnablerArguments = { $filterFormElement : $("[data-filter-form='true']"),
                                      filterEmailFieldSelector : ("[data-filter-email-field='true']"),
                                      filterProductFieldSelector : ("[data-filter-product-field='true']"),
                                      filterSubmitButtonSelector : ("[data-filter-submit-button]")
                                     },
      filterFormEnabler = new FilterFormEnabler(filterFormEnablerArguments);

  filterFormEnabler.init();
});

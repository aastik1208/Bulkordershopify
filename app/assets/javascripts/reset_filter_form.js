function Select2Resetter(options) {
  this.$formElement = options.$formElement;
  this.$formResetButtonElement = options.$formResetButtonElement;
  this.$selectElement = options.$selectElement;
}

Select2Resetter.prototype.init = function(){
  this.addResetSelect2Event();
};

Select2Resetter.prototype.addResetSelect2Event = function(){
  var _this = this;
  this.$formResetButtonElement.on('click', function(){
    _this.$formElement[0].reset();
    _this.$selectElement.trigger("change");
  });
};

$(function(){
  var filterFormSelect2ResetterArguments = { $formElement : $("[data-filter-form='true']"),
                                             $formResetButtonElement : $("[data-filter-reset-button='true']"),
                                             $selectElement : $("[data-filter-reset-select2='true']")
                                           },
      filterFormSelect2Resetter = new Select2Resetter(filterFormSelect2ResetterArguments);

  filterFormSelect2Resetter.init();
});

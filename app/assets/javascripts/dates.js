datefields = $('*[data-datefield]');
datefields.datepicker({
  dateFormat: 'MM d, yy',
  defaultDate: +7,
  minDate: '-12w',
  maxDate: '52w',
  showAnim: 'slideDown'
});
datefields.each(function(i, e) {
  e = $(e);
  if (e.val().toString().length > 0) {
    e.val($.datepicker.formatDate('MM d, yy', new Date(e.val())));
  }
});

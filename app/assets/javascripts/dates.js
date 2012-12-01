$(function() {
  $('*[data-datefield]').datepicker({
    dateFormat: 'yy-mm-dd',
    defaultDate: +7,
    minDate: '-12w',
    maxDate: '52w',
    showAnim: 'slideDown'
  })
});

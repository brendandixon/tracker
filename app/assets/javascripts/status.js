$(function() {
  $('body').on('change', '*[data-status-select]', function(event) {
    e = $(event.target);
    form = e.parents('FORM');
    if (e.val() === 'in_progress') {
      $('.start_date', form).show();
      $('.completed_date', form).hide();
    } else if (e.val() === 'completed') {
      $('.start_date', form).hide();
      $('.completed_date', form).show();
    } else {
      $('.start_date', form).hide();
      $('.completed_date', form).hide();
    }
  });
});

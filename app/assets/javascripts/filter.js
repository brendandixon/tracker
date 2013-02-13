$(function() {
  $('body').on('click', 'a[data-filter-toggle]', function(event) {
    $('*[data-filter]').slideToggle('fast', 'swing');
  });
  $('body').on('click', 'a[data-filter-link]', function(event) {
    $('#FilterMenu').dropdown('toggle');
    $('.waiter').show();
  });
  $('body').on('ajax:success', '*[data-filter] form', function(event, data, status, xhr) {
      $('*[data-filter]').slideUp('fast', 'swing');
  });
  $('body').on('click', '*[data-filter-close]', function(event) {
    $('*[data-filter]').slideUp('fast','swing');
  });
});

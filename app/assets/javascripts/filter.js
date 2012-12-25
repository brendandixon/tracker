$(function() {
  $('body').on('click', 'a[data-filter-toggle]', function(event) {
    $('*[data-filter]').slideToggle('fast', 'swing');
  })
  $('*[data-filter] form').bind('ajax:success', function(event, data, status, xhr) {
      $('*[data-filter]').slideUp('fast', 'swing');
  });
  $('body').on('click', '*[data-filter-close]', function(event) {
    $('*[data-filter]').slideUp('fast','swing');
  });
});

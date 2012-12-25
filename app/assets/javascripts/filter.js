$(function() {
  $('a[data-filter-toggle]').on('click', function(event) {
    $('*[data-filter]').slideToggle('fast', 'swing');
  })
  $('*[data-filter] form').bind('ajax:success', function(event, data, status, xhr) {
      $('*[data-filter]').slideUp('fast', 'swing');
  });
  $('*[data-filter] .close-filter').on('click', function(event) {
    $('*[data-filter]').slideUp('fast','swing');
  });
});

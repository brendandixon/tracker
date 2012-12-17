$(function() {
  $('a[data-filter-toggle]').on('click', function(event) {
    $('*[data-filter]').slideToggle('fast', 'swing');
  });
  $('*[data-filter] .close-filter').on('click', function(event) {
    $('*[data-filter]').slideUp('fast','swing');
  });
});

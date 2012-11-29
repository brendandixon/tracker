$(function() {
  $('a[data-filter-toggle]').on('click', function(event) {
    $('*[data-filter]').reveal();
  });
  $('*[data-filter] .close-filter').on('click', function(event) {
    $('*[data-filter]').trigger('reveal:close');
  });
});

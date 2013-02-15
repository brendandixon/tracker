$(function() {
  $('body').on('change', ".feature span input[type='radio']", function(event) {
    var e = $(event.target);
    var f = e.closest('.feature');
    f.find('i').removeClass('active');
    f.find('span[data-status='+e.attr('data-status')+'] i').addClass('active');
  });
});

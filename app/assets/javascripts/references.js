$(function() {
  $('body').on('click', 'a[data-add-reference]', function(event) {
    e = $(event.target);
    r = e.parents('.references');
    l = r.find('.references-list');
    t = r.find('.template');
    $(t.attr('data-contents')).appendTo(l);
  });
  $('body').on('click', 'a[data-remove-reference]', function(event) {
    e = $(event.target);
    r = e.parents('.reference');
    r.addClass('destroyed');
    r.find('*[data-destroy]').val(1);
  });
});

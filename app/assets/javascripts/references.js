$(function() {
  $('body').on('click', 'a[data-add-reference]', function(event) {
    var e = $(event.target);
    var r = e.parents('.references');
    var l = r.find('.references-list');
    var t = r.find('.template');
    $(t.attr('data-contents')).appendTo(l);
  });
  $('body').on('click', 'a[data-remove-reference]', function(event) {
    var e = $(event.target);
    var r = e.parents('.reference');
    r.addClass('destroyed');
    r.find('*[data-destroy]').val(1);
  });
  $('body').on('change', 'select[data-reference-type]', function(event) {
    var e = $(event.target);
    var s = $('option:selected', e).attr('data-tip');
    $('*[data-reference-tip]', e.closest('.reference')).attr('placeholder', s);
  });
});

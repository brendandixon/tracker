$(function() {
  $('body').on('click', '*[data-points]', function(event) {
    e = $(event.target);
    points = parseInt(e.attr('data-points'));
    pointsClass = points === 1
                    ? 'one-point'
                    : points === 2
                      ? 'two-points'
                      : points === 3
                        ? 'three-points'
                        : points === 4
                          ? 'four-points'
                          : 'five-points';
    e = e.closest('.points').children('.overlay');
    if (e.hasClass(pointsClass)) {
      points = 0;
      pointsClass = 'zero-points';
    }
    e.closest('.task_edit').find('input#task_points').val(points);
    e.removeClass('zero-points one-point two-points three-points four-points five-points').addClass(pointsClass);
  });
});

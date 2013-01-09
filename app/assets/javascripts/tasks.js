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
    task = e.closest('.task_edit');
    if (task.length > 0) {
      task.find('input#task_points').val(points);
    } else {
      task = e.closest('.task_inline');
      if (typeof task !== 'undefined') {
        task = task.attr('id').split('_')[1];
        $.ajax({
          type: 'POST',
          beforeSend: function(xhr){
            xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'))
          },
          dataType: 'script',
          url: '/tasks/' + task + '/point?points=' + points,
          error: function(jqXHR, textStatus, error) {
            $('#notice').html(textStatus).show().delay(1250).fadeOut(800);
          }
        });
      }
    }
    e.removeClass('zero-points one-point two-points three-points four-points five-points').addClass(pointsClass);
  });

  $('body').on('click', '.iteration_toggle', function(event) {
    e = $(event.target);
    e = e.parents('li.iteration_marker');
    if (e.length > 0) {
      e = e.eq(0);
      iteration = e.attr('data-iteration');
      $('li[data-iteration=' + iteration + ']:not(.iteration_marker)').toggle();
    }
  });

  $('body').on('bind.list', function(event) {
    $('#TaskList')
      .sortable({
        cursor: 'move',
        items: 'li:not(.iteration_marker)',
        opacity: 0.5,
        revert: true,
        scrollSensitiviy:5,
        scrollSpeed:100
      })
      .on('sortupdate', function(event, ui) {
        task = ui.item.eq(0);

        siblings = task.prevAll('li:not(.iteration_marker)');
        query = siblings.length > 0 ? 'after=' + siblings.eq(0).attr('id').split('_')[1] : '';

        if (query.length <= 0) {
          siblings = task.nextAll('li:not(.iteration_marker)');
          query = siblings.length > 0 ? 'before=' + siblings.eq(0).attr('id').split('_')[1] : '';
        }

        if (query.length > 0) {
          task = task.attr('id').split('_')[1];
          
          $.ajax({
            type: 'POST',
            beforeSend: function(xhr){
              xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'))
            },
            dataType: 'script',
            url: '/tasks/' + task + '/rank?' + query,
            error: function(jqXHR, textStatus, error) {
              $('#notice').html(textStatus).show().delay(1250).fadeOut(800);
              $('#TaskList').sortable('cancel');
            }
          });
        } else {
          $('#notice').html("Internal Error - Improper position").show().delay(1250).fadeOut(800);
        }    
      });
    $('#TaskList li').disableSelection();
  });
});

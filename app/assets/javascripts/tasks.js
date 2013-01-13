var Tracker = Tracker || {};
Tracker.Tasks = {};

Tracker.Tasks.getIterationState = function() {
  var c = $.cookie('iterations');
  if (c === null) {
    c = '0';
    $.cookie('iterations', c);
  }
  return c.split(',');
}

Tracker.Tasks.saveIterationState = function(iteration, fShow) {
  var c = $.cookie('iterations');
  c = (c === null ? [] : c.split(','));
  if (fShow) {
    c.push(iteration);
    c.sort();
    c = _.uniq(c, true);
  } else {
    c = _.without(c, iteration);
  }
  $.cookie('iterations', c.join());
};

Tracker.Tasks.toggleIteration = function(li, iteration, fShow) {
  if (fShow) {
    $('li[data-iteration=' + iteration + ']:not(.iteration_marker)').removeClass('hidden').addClass('visible');
    li.find('.glyphicon').removeClass('expand').addClass('collapse_top');
    li.attr('data-collapsed', 0);
  } else {
    $('li[data-iteration=' + iteration + ']:not(.iteration_marker)').removeClass('visible').addClass('hidden');
    li.find('.glyphicon').removeClass('collapse_top').addClass('expand');
    li.attr('data-collapsed', 1);
  }
};

$(function() {
  $('body').on('click', '*[data-points]', function(event) {
    var e, points, pointsClass;
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
    var e, iteration, collapsed;
    e = $(event.target);
    e = e.parents('li.iteration_marker');
    if (e.length > 0) {
      e = e.eq(0);
      iteration = e.attr('data-iteration');
      collapsed = e.attr('data-collapsed') !== '0';
      Tracker.Tasks.toggleIteration(e, iteration, collapsed);
      Tracker.Tasks.saveIterationState(iteration, collapsed);
    }
  });

  $('body').on('iteration.visibility', function(event) {
    var e, iteration, visible;
    visible = Tracker.Tasks.getIterationState();
    $('li.iteration_marker').each(function(i, e) {
      e = $(e);
      iteration = e.attr('data-iteration');
      Tracker.Tasks.toggleIteration(e, iteration, _.contains(visible, iteration));
    });
  });

  $('body').on('click', '#filter_content_group_by', function(event) {
    var e;
    e = $('#filter_content_group_by');
    if (e.length > 0) {
      e = e[0];
      if (e.checked) {
        $('.task_filter').hide();
        $('.task_iteration_filter').show();
      } else {
        $('.task_filter').show();
        $('.task_iteration_filter').hide();
      }
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
        var task, siblings, query;

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

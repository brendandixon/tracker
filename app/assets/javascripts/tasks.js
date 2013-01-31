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

Tracker.Tasks.toggleIteration = function(e, iteration, fShow) {
  if (fShow) {
    $('ol[data-iteration=' + iteration + ']').removeClass('hidden').addClass('visible');
    e.find('.glyphicon').removeClass('expand').addClass('collapse_top');
    e.attr('data-collapsed', 0);
  } else {
    $('ol[data-iteration=' + iteration + ']').removeClass('visible').addClass('hidden');
    e.find('.glyphicon').removeClass('collapse_top').addClass('expand');
    e.attr('data-collapsed', 1);
  }
};

$(function() {
  $('body').on('click', '*[data-points]', function(event) {
    var e, p, points, pointsClass;
    e = $(event.target);
    points = parseInt(e.attr('data-points'));
    pointsClass = points === 1
                    ? 'one-point'
                    : points === 2
                      ? 'two-points'
                      : points === 3
                        ? 'three-points'
                        : points === 5
                          ? 'five-points'
                          : 'eight-points';
    e = e.closest('.points').children('.overlay');
    if (e.hasClass(pointsClass)) {
      points = 0;
      pointsClass = 'zero-points';
    }
    task = e.closest('.task');
    if (task.length > 0) {
      if (task.hasClass('edit-mode')) {
        p = task.find('#task_points');
        if (p.length > 0) {
          p.val(points);
        }
      } else {
        id = task.attr('id').split('_')[1];
        query = 'points=' + points;
        if (task.children('.expanded').length > 0) {
          query += '&expanded=1';
        }
        $.ajax({
          type: 'POST',
          beforeSend: function(xhr){
            xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'))
          },
          dataType: 'script',
          url: '/tasks/' + id + '/point?' + query,
          error: function(jqXHR, textStatus, error) {
            $('#messages').html(textStatus).show().delay(1250).fadeOut(800);
          }
        });
      }
    }
    e.removeClass('zero-points one-point two-points three-points five-points eight-points').addClass(pointsClass);
  });

  $('body').on('click', '.iteration-toggle', function(event) {
    var e, iteration, collapsed;
    e = $(event.target);
    e = e.parents('.iteration-marker');
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
    $('.iteration-marker').each(function(i, e) {
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
        $('.task-filter').addClass('hidden');
      } else {
        $('.task-filter').removeClass('hidden');
      }
    }
  });

  $('body').on('bind.list', function(event) {
    $('.task-list')
      .sortable({
        cursor: 'move',
        connectWith: '.task-list',
        items: "li[data-status='pending']",
        opacity: 0.5,
        revert: true,
        scrollSensitiviy:5,
        scrollSpeed:100
      })
      .on('sortupdate', function(event, ui) {
        var task, siblings, query;

        task = ui.item.eq(0);

        siblings = task.nextAll('li:not(.iteration-marker)');
        query = siblings.length > 0 ? 'before=' + siblings.eq(0).attr('id').split('_')[1] : '';

        if (query.length <= 0) {
          siblings = task.prevAll('li:not(.iteration-marker)');
          query = siblings.length > 0 ? 'after=' + siblings.eq(0).attr('id').split('_')[1] : '';
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
              $('#messages').html(textStatus).show().delay(1250).fadeOut(800);
              $('#TaskList').sortable('cancel');
            }
          });
        } else {
          $('#messages').html("Internal Error - Improper position").show().delay(1250).fadeOut(800);
        }    
      });
    $('.task-list li').disableSelection();
  });
});

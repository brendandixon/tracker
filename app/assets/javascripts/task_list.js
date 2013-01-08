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

    sibilings = task.prevAll('li:not(.iteration_marker)');
    query = sibilings.length > 0 ? 'after=' + siblings.eq(0).attr('id').split('_')[1] : '';

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

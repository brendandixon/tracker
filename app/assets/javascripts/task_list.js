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

    after = task.prevAll('li:not(.iteration_marker)');
    after = after.length > 0 ? after.eq(0).attr('id').split('_')[1] : '';

    before = task.nextAll('li:not(.iteration_marker)');
    before = before.length > 0 ? before.eq(0).attr('id').split('_')[1] : '';
    
    task = task.attr('id').split('_')[1];
    
    $.ajax({
      type: 'POST',
      beforeSend: function(xhr){
        xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'))
      },
      dataType: 'script',
      url: '/tasks/' + task + '/rank?after=' + after + '&before=' + before,
      error: function(jqXHR, textStatus, error) {
        $('#notice').html(textStatus).show().delay(1250).fadeOut(800);
        $('#TaskList').sortable('cancel');
      }
    });
  });
$('#TaskList li').disableSelection();

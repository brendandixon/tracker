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
    task = $(ui.item[0]);

    before = task.next();
    before = before.length > 0 ? before.attr('id').split('_')[1] : '';
    
    after = task.prev();
    after = after.length > 0 ? after.attr('id').split('_')[1] : '';

    task = task.attr('id').split('_')[1];
    
    $.ajax({
      type: 'POST',
      beforeSend: function(xhr){
        xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'))
      },
      dataType: 'script',
      url: '/tasks/' + task + '/rank?before=' + before + '&after=' + after,
      error: function(jqXHR, textStatus, error) {
        $('#notice').html(textStatus).show().delay(1250).fadeOut(800);
        $('#TaskList').sortable('cancel');
      },
      success: function(data, textStatus, jqXHR) {
        $('#TaskList').sortable('refreshPositions');
        $('#Tasks li:nth-child(even)').removeClass('odd').addClass('even');
        $('#Tasks li:nth-child(odd)').removeClass('even').addClass('odd');
      }
    });
  });
$('#TaskList li').disableSelection();

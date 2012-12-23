$('#TaskList')
  .sortable()
  .on('sortupdate', function(event, ui) {
    $('#Tasks li:nth-child(even)').removeClass('odd').addClass('even');
    $('#Tasks li:nth-child(odd)').removeClass('even').addClass('odd');
  })

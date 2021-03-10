var clipboard = new ClipboardJS('.js-copy');

clipboard.on('success', function(e) {
    console.log(e);
/*    $('#alert_' + e.text).html('<button style="background-color: white;" class="btn">copied<br/>&#128077;</button>').fadeIn(1000).delay(2000).fadeOut(1000);*/
    $('#alert_' + e.text).html('<i class="glyphicon glyphicon-thumbs-up"><br/>' + e.text + '<br/>copied</i>').fadeIn(1000).delay(1000).fadeOut(1000);
    e.clearSelection();
});

clipboard.on('error', function(e) {
    console.log(e);
});
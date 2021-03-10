$(document).on('keydown', function() {
        var input = $('input[name="typeautofocus"]');
        var input2 = $('input[name="nofocus"]');
        
        if(!(input.is(':focus') || input2.is(':focus'))){
        input.focus();
        }
        
});
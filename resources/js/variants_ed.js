$(document).ready(function(){
    var next = $('.input-append').length;
    $(".add-more").click(function(e){
        e.preventDefault();
        var addto = "#field" + next;
        next = next + 1;
        var newIn = '<input class="form-control" id="field' + next + '" name="pladdname" ref="' + next + '" type="text"/>';
        var newInput = $(newIn);
        $(addto).after(newInput);
        $("#field" + next).attr('data-source',$(addto).attr('data-source'));
        $("#count").val(next);
        
    });
    
     $(".remove").click(function(e){
     e.preventDefault();
     	if(next==1){
          alert("No more variants to remove");
          return false;
       }
     
     $("#field" + next).remove();
     next = next - 1;
     $("#count").val(next);
     });

});
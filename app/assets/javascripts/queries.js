$(document).ready(function(){
  $("#query_start_save").click(function(){
    $(this).hide("fast");
    $("#query_saving").show("fast");
  });

  $("#query_save").click(function(){
    var code = $('#query_saving').attr('data');

    var name = $('#name').val();
    var desc = $('#desc').val()
    var query = $('#query_content').val();

    $.ajax({
      type: 'POST',
      url: '/ontologies/'+code+'/queries',
      data: { content: [name,desc,query] },
      success: function (data) {
        // if ok
          // hide #query_saving
          // clear #name value
          // clear #desc value
          // show #query_saved
          // show #query_start_save
        // else
          // create alert-danger with errors
      },
      fail: function(data) {
        // create alert-danger with errors
      }
    });
  });

  $("#new-query").click(function(){
    var container = $("#new-query-container");
    if( $("#new-query-container").css('display') == 'none' ){
      $("#new-query-container").show("fast");
      $(this).children().first().removeClass("fa-plus").addClass("fa-minus");
    }else{
      $("#new-query-container").hide("fast");
      $(this).children().first().removeClass("fa-minus").addClass("fa-plus");
    }
    return false;
  });
});

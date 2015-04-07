$(document).ready(function(){
  $("#button_save").click(function(){
    var name = "<label>Title: </label><input id=\"name\" type=\"text\">";
    var desc = "<label>Description: </label><input id=\"desc\" type=\"text\">";
    var notice = "Necessários preencher próximos campos!";

    $("#name_space").append(name);
    $("#desc_space").append(desc);
    $("#notice").append(notice);

    $("#button_save").remove();
    $("#save_space").append("<a>Save</a>")
  });

  $("#save_space").click(function(){
    var code = $('#save_space').attr('data');

    var name = $('#name').val();
    var desc = $('#desc').val()
    var query = $('#query_content').val();
    var content = [name,desc,query];

    $.ajax({
      type: 'POST',
      url: '/ontologies/'+code+'/queries',
      data: { content: content },
      success: function (data) {
        if (data.substring(0, 6) == "Error:") {
            $("#notice").text(data);
        }else $("#notice").text("Query Saved!");
      },
      fail: function(data) {
        $("#notice").text("Errors!");
      }
    });
  });
});

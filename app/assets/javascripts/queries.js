$(document).ready(function(){
  $("a#run_query").click(function(){
    var code = $(this).data('ontology');
    var content = $('span#content').text();

    $.ajax({
      type: 'POST',
      url: '/ontologies/'+code+'/queries',
      data: { content: content },
      success: function (data) {
        alert('asdasda');
      }
    });
  });
});

function objToString (obj) {
    var str = '';
    for (var p in obj) {
        if (obj.hasOwnProperty(p)) {
            str += p + '::' + obj[p] + '\n';
        }
    }
    return str;
}

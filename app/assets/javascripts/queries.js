$(document).ready(function(){
  $("#prefixes_add").click(function(){
    $("#query_content").val(function(index, value){
      var options = $("#prefixes_select option");
      var sel = $("#prefixes_select")[0];
      var ind = sel.selectedIndex;
      var new_index = 0;
      var new_array = [];
      for (var i = 0; i < options.length; i++) {
        if(options[i].parentNode.nodeName != "SPAN"){
          new_array[new_index] = options[i];
          new_index++;
        }
      };
      return new_array[ind].getAttribute('value') + "\n" + value;
    }).trigger("input");

    autosize.update($("#query_content"));
  });

  $("#prefixes_add_all").click(function(){
    var lines = [];

    $('#prefixes_select option').each(function() {
      if(!$(this).parent().is("span")) //do not add hidden options
        lines.push($(this).val());
    });

    $("#query_content").val(function(index, value){
      return lines.join("\n") + "\n" + value
    }).trigger("input");

    autosize.update($("#query_content"));
  });

  $("#query_start_save").click(function(){
    $(this).hide("fast");
    $("#query_saving").show("fast");
  });

  $('#query_stop_save').click(function(){
    $('#query_saving').hide('fast');
    $('#query_start_save').show('fast');
    $('#name').val('');
    $('#desc').val('');
  });

  $("#query_save").click(function(){
    $(this).attr('disabled','disabled');

    var code = $('#query_saving').attr('data');

    var name = $('#name').val();
    var desc = $('#desc').val();
    var content = $('#query_content').val();

    $.ajax({
      type: 'POST',
      url: '/ontologies/'+code+'/queries',
      data: {
        query: {
          name: name,
          desc: desc,
          content: content
        }
      },
      success: function (response) {
        if(response.error.length == 0){
          $('#query_saving').hide('fast');
          $('#query_start_save').show('fast');
          $('#name').val('');
          $('#desc').val('');
          $("#query_save").removeAttr('disabled');

          $('#query_save_area').prepend(
            '<div class="alert alert-success alert-border" style="display: none;">' +
            '<button class="close" type="button" data-dismiss="alert" aria-hidden="true">&times;</button>' +
            'Query was successfully created. ' +
            '<a href="' + response.url + '">View query</a></div>'
          );

          $('#query_save_area div.alert').show('fast');
        }else{
          $("#query_save").removeAttr('disabled');
          $('#query_save_area').prepend(function(){
            var html = '<div class="alert alert-danger alert-border" style="display: none;">' +
            '<button class="close" type="button" data-dismiss="alert" aria-hidden="true">&times;</button>' +
            '<ul>';

            $.each(response.error, function(index, value){
              html += '<li>' + value + '</li>';
            });

            html += '</ul></div>';
            return html;
          });

          $('#query_save_area div.alert').show('fast');
        }
      },
      error: function(httpRequest, status, error) {
        $("#query_save").removeAttr('disabled');
        $('#query_save_area').prepend(
          '<div class="alert alert-danger alert-border" style="display: none;">' +
          '<button class="close" type="button" data-dismiss="alert" aria-hidden="true">&times;</button>' +
          '<ul><li>' + status + ': ' + error + '</li></ul></div>'
        );
        $('#query_save_area div.alert').show('fast');
      }
    });
  });

  $("#new-query").click(function(){
    var container = $("#new-query-container");
    if( $("#new-query-container").css('display') == 'none' ){
      $("#new-query-container").show("fast");
      $(this).children().first().removeClass("fa-plus").addClass("fa-minus");
      $(this).addClass('icon-ar-info', 'fast');
    }else{
      $("#new-query-container").hide("fast");
      $(this).children().first().removeClass("fa-minus").addClass("fa-plus");
      $(this).removeClass('icon-ar-info', 'fast');
    }
    return false;
  });

  $("#s_classes").click(function(){
    $("#query_content").val("SELECT DISTINCT ?class WHERE {\n [] a ?class\n} ORDER BY ?class");
    $("#submit_query").submit();
  });

  $("#s_properties").click(function(){
    $("#query_content").val("SELECT DISTINCT ?property WHERE {\n [] ?property []\n} ORDER BY ?property");
    $("#submit_query").submit();
  });

  $("#s_topconcepts").click(function(){
    $("#query_content").val("PREFIX skos: <http://www.w3.org/2004/02/skos/core#>\n\nSELECT DISTINCT ?topConcept ?prefLabel WHERE {\n ?base skos:hasTopConcept ?topConcept.\n ?topConcept skos:prefLabel ?prefLabel.\n FILTER(lang(?prefLabel) = \"en\")\n} ORDER BY ?prefLabel");
    $("#submit_query").submit();
  });

  autosize($('textarea'));
  checkPrefixes();
});

function checkPrefixes(){
  var elem = document.getElementById('prefixes_select');
  if(elem == null) return;
  var prefs = elem.children;
  var text = document.getElementById('query_content').value;
  var active = 0;
  for (index = 0; index < prefs.length; ++index) {
    var node = prefs[index];
    if(node.nodeName == "SPAN") //the hidden elements
      node = node.children[0]; //fetch the option element

    var value = node.value;
    var menor = value.indexOf("<");
    var maior = value.indexOf(">");
    var subs = value.substring(menor, maior + 1);

    if(text.indexOf(subs) > -1) //the prefix exists in the text
      jQuery('#prefixes_select option[value="'+value+'"]').toggleOption(false);
    else{
      jQuery('#prefixes_select option[value="'+value+'"]').toggleOption(true);
      active++;
    }
  }
  if(active > 0)
    $("#div_prefixes").show();
  else $("#div_prefixes").hide();
}

jQuery.fn.toggleOption = function( show ) {
    jQuery( this ).toggle( show );
    if( show ) {
        if( jQuery( this ).parent( 'span.toggleOption' ).length )
            jQuery( this ).unwrap( );
    } else {
        if( jQuery( this ).parent( 'span.toggleOption' ).length == 0 )
            jQuery( this ).wrap( '<span class="toggleOption" style="display: none;" />' );
    }
};

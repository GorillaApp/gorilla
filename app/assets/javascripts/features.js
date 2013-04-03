$(function() {
    $( "#featuredialog" ).dialog({
      autoOpen: false,
      show: {
        effect: "slide",
        duration: 1000
      },
      hide: {
        effect: "drop",
        duration: 1000
      }
    });
 
    $( "#addfeature" ).click(function() {
      $( "#featuredialog" ).dialog( "open" );
    });
  });

$(function() {
    $( "#allfeaturesdialog" ).dialog({
      autoOpen: false,
      show: {
        effect: "slide",
        duration: 1000
      },
      hide: {
        effect: "drop",
        duration: 1000
      }
    });
 
    $( "#allfeatures" ).click(function() {
       if (allFeatures == null) {
        json_request(
          'GET',
          "/feature/getAll",
          {user_id: user},
          function(data) { allFeatures = data; },
          function(err) {   }
        );
      }

      var table=document.getElementById("featureTbl");
      for (var i = 0; i < allFeatures.length; i++) {
        var feat = allFeatures[i];

        var row=table.insertRow(-1);

        var cell1=row.insertCell(0);
        var cell2=row.insertCell(1);
        var cell3=row.insertCell(2);
        var cell4=row.insertCell(3);
        var cell4=row.insertCell(4);

        cell1.innerHTML = feat.id;
        cell2.innerHTML = feat.name;
        cell3.innerHTML = feat.sequence;
        cell4.innerHTML = feat.forward_color;
        cell5.innerHTML = feat.reverse_color;   
        cell6.innerHTML = "<a href='/feature/delete?id="+feat.id+"&user_id="+user_id+"'>Delete Feature</a>";
      }    

      $( "#allfeaturesdialog" ).dialog( "open" );
    });
  });

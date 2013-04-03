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
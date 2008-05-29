TuneUp.switchSchema = function(table) {
  var element = $('tuneup-schema-table-' + table);
  var operation = element.visible() ? 'hide' : 'show';
  $$('#tuneup-schema .tuneup-schema-table').each(function(s) { s.hide(); })
  element[operation]();
  $('tuneup-schema')[operation]();
}
TuneUp.Spinner = {
  start: function() { $('tuneup_spinner').show(); },
  stop: function() { $('tuneup_spinner').hide(); }
}


Event.observe(window, 'load', function() {
  $A($(document.body).descendants()).each(function(e){
    var pos = Element.getStyle(e, 'position');
    if(pos == 'absolute' || pos == 'fixed') {
     var top = parseFloat(Element.getStyle(e, 'top') || 0);
     e.style.top = (top + 50) + 'px'; 
    }
  })
  new Insertion.Top(document.body, "<div id='tuneup'><h1>FiveRuns TuneUp</h1><img id='tuneup_spinner' style='display:none' src='/images/tuneup/spinner.gif' alt=''/><div id='tuneup-content'></div></div><div id='tuneup-flash'></div>");
  new Ajax.Request('/tuneup?uri=' + encodeURIComponent(document.location.href),
    {
      asynchronous:true,
      evalScripts:true,
      onLoading: TuneUp.Spinner.start,
      onComplete: TuneUp.Spinner.stop
    });
});

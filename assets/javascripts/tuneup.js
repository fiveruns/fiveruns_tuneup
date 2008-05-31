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

TuneUp.adjust_positioned_element = function(e) {
	var pos = e.getStyle('position');
	if (pos == 'absolute' || pos == 'fixed') {
		var top = parseFloat(e.getStyle('top') || 0);
    e.style.top = (top + 50) + 'px';
		e.immediateDescendants().each(function(e) { TuneUp.adjust_positioned_element(e) });
	}
	else if (pos == 'relative') {
		// do nothing
	}
	else {
		e.immediateDescendants().each(function(e) { TuneUp.adjust_positioned_element(e) });
	}
}

Event.observe(window, 'load', function() {
	document.body.immediateDescendants().each(function(e) {
		TuneUp.adjust_positioned_element(e);
	});
	
  new Insertion.Top(document.body, "<div id='tuneup'><h1>FiveRuns TuneUp</h1><img id='tuneup_spinner' style='display:none' src='/images/tuneup/spinner.gif' alt=''/><div id='tuneup-content'></div></div><div id='tuneup-flash'></div>");
  new Ajax.Request('/tuneup?uri=' + encodeURIComponent(document.location.href),
    {
      asynchronous:true,
      evalScripts:true,
      onLoading: TuneUp.Spinner.start,
      onComplete: TuneUp.Spinner.stop
    });
});



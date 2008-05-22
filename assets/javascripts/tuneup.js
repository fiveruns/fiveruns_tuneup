Event.observe(window, 'load', function() {
  new Insertion.Top(document.body, "<div id='tuneup'><h3>TuneUp</h3><div id='tuneup-content'></div></div><div id='tuneup-flash'></div>");
  new Ajax.Request('/tuneup?uri=' + encodeURIComponent(document.location.href), {asynchronous:true, evalScripts:true});
});
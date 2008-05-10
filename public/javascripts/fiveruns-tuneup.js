Event.observe(window, 'load', function() {
  new Insertion.Top(document.body, "<div id='fiveruns-tuneup'><h3>TuneUp</h3><div id='fiveruns-tuneup-content'></div></div>");
  new Ajax.Request('/tuneup', {asynchronous:true, evalScripts:true});
});
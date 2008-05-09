// Requires Prototype 1.6+
document.observe('contentloaded', function() {
  // TODO: Real AJAX Request
  Insertion.Top(document.body, "<div id='fiveruns-tuneup'><p>Some text!</p></div>");
});
var _window   = window.parent,    // window obj of the main page
    page = $(_window.document); // document obj of the main page
    
var TuneUp = {
  imagePath: '/fiveruns_tuneup_rails/images',
  parentStepOf: function(e) {
    return e.parent().parent().parent();
  },
  adjustFixedElements: function(e) {
    page.find('*').each(function() {
      if($(this).css("position") == "fixed") {
        TuneUp.adjustElement(e);
      }
  	});
  },
  adjustElement: function(e) {
    var element = $(e)
  	var top = parseFloat(element.css('top') || 0);
  	var adjust = 0;
  	if(!element.hasClass('tuneup-flash-adjusted')) {
      adjust = page.find('#tuneup-flash.tuneup-show').length ? 27 : -27;
    	element.addClass('tuneup-flash-adjusted');
    }
  	if (element.hasClass('tuneup-adjusted')) {
  	  element.css({top: (top + adjust) + 'px'});
  	} else {
  	  element.css({top: (top + 50 + adjust) + 'px'});
  		element.addClass('tuneup-adjusted');
  	}
  },
  adjustAbsoluteElements: function(base) {
    $(base).find('> *[id!=tuneup]').each(function() {
      switch($(this).css('position')) {
      case 'absolute':
        TuneUp.adjustElement(this);
    		TuneUp.adjustAbsoluteElements(this);
        break;
      case 'relative':
        // Nothing
        break;
      default:
        TuneUp.adjustAbsoluteElements(this);
      }
    });
  }
}
        
$(window).ready(function() {
        
  page.find('#tuneup-save-link').click(function () {
    var link = $(this);
    link.hide();
    $.getJSON($(this).attr('href'), {}, function(data) {
      if (data.run_id) {
        var url = "http://tuneup.fiveruns.com/runs/" + data.run_id;
        var goToRun = function() {
          if(!_window.open(url)) { page.location = url; }
          return false;
        }
        link.html("Shared!");
        link.click(goToRun);
        goToRun();
      } else if (data.error) {
        alert(data.error);
      }
      link.show();
    });
    return false;
  });
    
  page.find('#tuneup .with_children .tuneup-title a.tuneup-step-name').toggle(
    // Note: Simple 'parent' lookup with selector doesn't seem to work
    function() { TuneUp.parentStepOf($(this)).addClass('tuneup-opened'); },
    function() { TuneUp.parentStepOf($(this)).removeClass('tuneup-opened'); }                
  );
  
  page.find('.tuneup-step-extras').hide().find('> div').prepend($('<a class="tuneup-close-link" href="#">Close</a>').click(function() {
    $(this).parent().parent().hide();
  }));
  page.find('#tuneup .with_children .tuneup-title a.tuneup-step-extras-link').html(
    $("<img src='" + TuneUp.imagePath + "/magnify.png' alt=''/>")
  ).toggle(
    function() { TuneUp.parentStepOf($(this)).find('> .tuneup-step-extras').show(); },
    function() { TuneUp.parentStepOf($(this)).find('> .tuneup-step-extras').hide(); }
  )
  
  page.find('.tuneup-step-extra-extended').hide().each(function() {
    var extended = $(this);
    extended.before('<br/>');
    extended.before($('<a class="tuneup-more-link" href="#">(Show&nbsp;' + extended.attr('title') + ')</a>').toggle(
      function() { extended.show(); $(this).html('(Hide&nbsp;' + extended.attr('title') + ')'); return false; },
      function() { extended.hide(); $(this).html('(Show&nbsp;' + extended.attr('title') + ')'); return false; }
    ));
  });
    
  TuneUp.adjustFixedElements(page);
});
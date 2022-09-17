$(function(){
	setTimeout(function() {
	  $('#doc').addClass('show');
	}, 100);

	$('.lm-close').click(function(){
		$('#doc').addClass('no-pad');
	})
	$('.lm-open').click(function(){
		$('#doc').removeClass('no-pad');
	})
});	
function clearText(thefield) {
  if (thefield.defaultValue==thefield.value) {
    thefield.value="";
  }
} 
function defaultText(thefield) {
  if (thefield.value=="") {
    thefield.value=thefield.defaultValue;
  }
}
function sizeControlCommon(width) {
	width = parseInt(width);
	var bodyHeight = document.documentElement.clientHeight; 
	var bodyWidth = document.documentElement.clientWidth; 
	var chkHeader = $('#header-wrap').outerHeight();
	var chkFooter = $('#footer').outerHeight();
	var docH = $('#doc').innerHeight();
	
}
jQuery(function($){
	sizeControlCommon($(this).width());
	$(window).resize(function() {
		if(this.resizeTO) {
			clearTimeout(this.resizeTO);
		}
		this.resizeTO = setTimeout(function() {
			$(this).trigger('resizeEnd');
		}, 10);
	});
});	
$(window).on('resizeEnd', function() {
	sizeControlCommon($(this).width());
});
$(window).load( function() { 
	sizeControlCommon($(this).width());
});


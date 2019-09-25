$(document).ready(function(){
	$(".menu").click(function(e){
      $(".menu-list").toggle();
      e.stopPropagation();
	});
	$(document).click(function(){
		$(".menu-list").hide();
	});
	
});

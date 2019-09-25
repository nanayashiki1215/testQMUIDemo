define(function(require){
	var $ = require("jquery");
	var justep = require("$UI/system/lib/justep");
	
	var Model = function(){
		this.callParent();
	};
	$(".inspectwindow").click(function(e){
	     e.stopPropagation();
		});
	
	Model.prototype.span1Click = function(event){
	var windowReceiver=this.comp("windowReceiver1");
	windowReceiver.windowEnsure();
		justep.Shell.showPage("doPlan");
	};

	Model.prototype.span2Click = function(event){
		var windowReceiver=this.comp("windowReceiver1");
		windowReceiver.windowEnsure();
		justep.Shell.showPage("assignment");
		
	};

	Model.prototype.span3Click = function(event){
		var windowReceiver=this.comp("windowReceiver1");
		windowReceiver.windowEnsure();
		justep.Shell.showPage("queryAll");
	};






	return Model;
});
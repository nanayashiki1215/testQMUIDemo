define(function(require){
	var $ = require("jquery");
	var justep = require("$UI/system/lib/justep");
	
	var Model = function(){
		this.callParent();
	};

	Model.prototype.span11Click = function(event){
		justep.Shell.showPage("mainpage");
	};

	Model.prototype.li1Click = function(event) {
		justep.Shell.showPage("alarm");
	};

	return Model;
});
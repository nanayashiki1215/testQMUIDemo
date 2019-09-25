define(function(require){
	var $ = require("jquery");
	var justep = require("$UI/system/lib/justep");
	var versionChecker=require("$UI/system/components/justep/versionChecker/versionChecker");
	var Model = function(){
		this.callParent();
	};

	Model.prototype.updateClick = function(event){
		versionChecker.check();
	};

	return Model;
});
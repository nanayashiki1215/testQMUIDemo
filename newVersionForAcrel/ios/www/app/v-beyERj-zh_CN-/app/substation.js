define(function(require) {
	var $ = require("jquery");
	var justep = require("$UI/system/lib/justep");

	var Model = function() {
		this.callParent();
	};

	Model.prototype.button3Click = function(event) {
		var subid = event.bindingContext.$object.toJson({
			format : 'simple'
		}).f_SubID;
		justep.Shell.showPage("detali", {
			"subid" : subid
		});
	};

	var subdata;
	var userid;
	var ipAdress;
	Model.prototype.modelParamsReceive = function(event) {
		userid = JSON.parse(localStorage.getItem("userUUID")).userid;
		subdata = this.comp("subdata");
		ipAdress = localStorage.getItem("ipAdress");
		var url = "http://" + ipAdress + "/SubstationOperation/rest/app/selectsubstationinfo";
		$.ajax({
			type : "get",
			async : false,
			data : "Userid=" + userid,
			url : url,
			cache : false,
			dataType : "jsonp",
			jsonp : "Callback",
			jsonpCallback : "successCallback",
			success : function(success) {
				subdata.clear();
				if (success != null)
					subdata.loadData(success.list);
			}
		});
	};

	Model.prototype.li1Click = function(event) {
		justep.Shell.closeAllOpendedPages();
	};

	Model.prototype.li2Click = function(event){
		justep.Shell.showPage("alarm");
	};
	
	
	return Model;
});
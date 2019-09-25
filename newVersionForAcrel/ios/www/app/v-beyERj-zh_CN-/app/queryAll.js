define(function(require) {
	var $ = require("jquery");
	var justep = require("$UI/system/lib/justep");

	var Model = function() {
		this.callParent();
	};
	var plandata;
	var userid;
	var ipAdress;
	Model.prototype.modelParamsReceive = function(event) {
		plandata = this.comp("plandata");
		userid = JSON.parse(localStorage.getItem("userUUID")).userid;

		ipAdress = localStorage.getItem("ipAdress");
		var url = "http://" + ipAdress + "/SubstationOperation/rest/app/selectAssignedGroupPlan";
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
				plandata.clear();
				if (success != null)
					plandata.loadData(success);
			}
		});
	};

	Model.prototype.modelActive = function(event) {
		plandata = this.comp("plandata");
		userid = JSON.parse(localStorage.getItem("userUUID")).userid;
		var url = "http://" + ipAdress + "/SubstationOperation/rest/app/selectAssignedGroupPlan";
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
				plandata.clear();
				if (success != null)
					plandata.loadData(success);
			}
		});
	};

	Model.prototype.li1Click = function(event) {
		justep.Shell.closeAllOpendedPages();

	};

	Model.prototype.li2Click = function(event) {
		justep.Shell.showPage("alarm");
	};

	return Model;
});
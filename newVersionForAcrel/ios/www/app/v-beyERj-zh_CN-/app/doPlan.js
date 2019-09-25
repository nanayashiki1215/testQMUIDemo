define(function(require) {
	var $ = require("jquery");
	var justep = require("$UI/system/lib/justep");

	var Model = function() {
		this.callParent();
	};

	Model.prototype.button3Click = function(event) {
		var params = event.bindingContext.$object.toJson({
			format : 'simple'
		});
		justep.Shell.showPage("execute", params);
	};
	var userid;
	var plandata;
	var ipAdress;
	Model.prototype.modelParamsReceive = function(event) {
		userid = JSON.parse(localStorage.getItem("userUUID")).userid;
		plandata = this.comp("plandata");

		ipAdress = localStorage.getItem("ipAdress");
		var url = "http://" + ipAdress + "/SubstationOperation/rest/app/selectownplan";
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
		var url = "http://" + ipAdress + "/SubstationOperation/rest/app/selectownplan";
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
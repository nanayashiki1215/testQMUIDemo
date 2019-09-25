define(function(require) {
	var $ = require("jquery");
	var justep = require("$UI/system/lib/justep");

	var Model = function() {
		this.callParent();
	};
	var userid;
	var assigndata;
	var ipAdress;
	Model.prototype.button3Click = function(event) {
		assigndata = this.comp("assigndata");

		var assignparams = event.bindingContext.$object.toJson({
			format : 'simple'
		});

		this.comp("assignDialog").open({
			data : assignparams
		});
	};

	Model.prototype.modelParamsReceive = function(event) {
		userid = JSON.parse(localStorage.getItem("userUUID")).userid;
		ipAdress = localStorage.getItem("ipAdress");
		var url = "http://"+ipAdress+"/SubstationOperation/rest/app/selectgroupplan";
		assigndata = this.comp("assigndata");
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
				assigndata.clear();
				if (success !== null)
					assigndata.loadData(success);
			}
		});
	};

	Model.prototype.assignDialogClose = function(event) {
		var url = "http://"+ipAdress+"/SubstationOperation/rest/app/selectgroupplan";
		assigndata = this.comp("assigndata");
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
				assigndata.clear();
				if (success !== null)
					assigndata.loadData(success);

			}
		});
	};

	Model.prototype.li1Click = function(event) {
		justep.Shell.closeAllOpendedPages();
	};

	Model.prototype.li2Click = function(event) {
		justep.Shell.showPage("alarm");
	};

	Model.prototype.modelActive = function(event) {

	};

	return Model;
});
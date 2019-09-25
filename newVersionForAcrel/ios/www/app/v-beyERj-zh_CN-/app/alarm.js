define(function(require) {
	var $ = require("jquery");
	var justep = require("$UI/system/lib/justep");

	var Model = function() {
		this.callParent();
	};
	var userid;
	Model.prototype.modelLoad = function(event) {
		userid = JSON.parse(localStorage.getItem("userUUID")).userid;
		
		var ipAdress = localStorage.getItem("ipAdress");
		var url = "http://"+ipAdress+"/SubstationOperation/rest/app/getnoreadevent";
		
		var noreadeventdata = this.comp("noreadeventdata");
	
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
				if (success!==null) {
					noreadeventdata.clear();
					noreadeventdata.loadData(success);
				}
			}
		});
	};

	Model.prototype.li1Click = function(event) {
		justep.Shell.closeAllOpendedPages();
	};

	Model.prototype.li2Click = function(event){
		justep.Shell.showPage("contact");
	};

	return Model;
});
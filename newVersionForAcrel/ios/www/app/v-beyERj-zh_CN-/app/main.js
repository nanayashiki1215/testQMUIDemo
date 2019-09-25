define(function(require) {
	var $ = require("jquery");
	var justep = require("$UI/system/lib/justep");
	require('./js/main');
	require("$UI/system/lib/cordova/cordova");
	var jpushInstance = require("./jpush");
	var Model = function() {
		this.callParent();
	};
	var regid;
	var userid;
	var intervalID1;
	var intervalID2;
	var ipAdress;
	Model.prototype.span2Click = function(event) {
		justep.Shell.showPage("substation");
	};

	Model.prototype.myModal2Click = function(event) {
		this.comp("windowDialog1").open();
	};

	Model.prototype.span3Click = function(event) {
		justep.Shell.showPage("event");
	};
	Model.prototype.mapClick = function(event) {
		justep.Shell.showPage("map");
	};

	Model.prototype.logoutClick = function(event) {
		this.comp('logout').show($('.OK').text("取消"), $('.Cancel').text("确认"));
	};

	Model.prototype.logoutOK = function(event) {
		localStorage.removeItem("userUUID");
		clearInterval(intervalID1);
		clearInterval(intervalID2);
		this.comp("loginDialog").open();
		//window.location.reload();
	};

	Model.prototype.div1Click = function(event) {
		this.comp("windowDialog1").close();
	};

	Model.prototype.modelLoad = function(event) {
		intervalID1 = setInterval(alarmevent, 10000);
		if (localStorage.getItem("userUUID") != null) {
			userid = JSON.parse(localStorage.getItem("userUUID")).userid;
			jpushInstance.getRegistrationID().done(function(id) {
				regid = id;
			});
			
			ipAdress = localStorage.getItem("ipAdress");
			var url = "http://" + ipAdress + "/SubstationOperation/rest/app/insertregid";
			
			$.ajax({
				type : "get",
				async : false,
				data : "Userid=" + userid + "&Regid=" + regid,
				url : url,
				cache : false,
				dataType : "jsonp",
				jsonp : "Callback",
				jsonpCallback : "successCallback",
				success : function(success) {
					if (success !== 0)
						$('#eventnum').html(success);
					else
						$('#eventnum').html('');
				}
			});
		}
	};

	Model.prototype.li1Click = function(event) {
		justep.Shell.showPage("alarm");
	};

	function alarmevent(event) {
		if (localStorage.getItem("userUUID") != null) {
			userid = JSON.parse(localStorage.getItem("userUUID")).userid;
			var url = "http://" + ipAdress + "/SubstationOperation/rest/app/getnoreadeventnum";
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
					if (success !== 0)
						$('#eventnum').html(success);
					else
						$('#eventnum').html('');
				}

			});
		}
	}

	Model.prototype.modelActive = function(event) {
		alarmevent(event);
		intervalID2 = setInterval(alarmevent, 3000);
	};

	Model.prototype.modelInactive = function(event) {
		clearInterval(intervalID1);
		clearInterval(intervalID2);
	};

	Model.prototype.li2Click = function(event){
		justep.Shell.showPage("contact");
	};

	Model.prototype.span1Click = function(event){
		justep.Shell.showPage("electricData");
	};

	Model.prototype.safespanClick = function(event){
		justep.Shell.showPage("safeEnergy");
	};

	Model.prototype.videoClick = function(event){
		justep.Shell.showPage("video");
	};

	return Model;
});
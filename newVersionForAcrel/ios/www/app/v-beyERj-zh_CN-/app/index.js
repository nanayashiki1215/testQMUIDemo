define(function(require) {
	var $ = require("jquery");
	var justep = require("$UI/system/lib/justep");
	var ShellImpl = require('$UI/system/lib/portal/shellImpl');
	require("./js/appVersionChecker");
	
	var Model = function() {
		this.callParent();
		var shellImpl = new ShellImpl(this, {
			"contentsXid" : "pages",
			"pageMappings" : {
				"mainpage" : {
					url : require.toUrl('./main.w')
				},
				"detali" : {
					url : require.toUrl('./detali.w')
				},
				"distribute" : {
					url : require.toUrl('./distribute.w')
				},
				"execute" : {
					url : require.toUrl('./execute.w')
				},
				"index" : {
					url : require.toUrl('./index.w')
				},
				"inspect" : {
					url : require.toUrl('./inspect.w')
				},
				"substation" : {
					url : require.toUrl('./substation.w')
				},
				"assignment" : {
					url : require.toUrl('./assignment.w')
				},
				"doPlan" : {
					url : require.toUrl('./doPlan.w')
				},
				"queryAll" : {
					url : require.toUrl('./queryAll.w')
				},
				"event" : {
					url : require.toUrl('./event.w')
				},
				"map" : {
					url : require.toUrl('./map.w')
				},
				"login" : {
					url : require.toUrl('./login.w')
				},
				"alarm" : {
					url : require.toUrl('./alarm.w')
				},
				"overlimitevent" : {
					url : require.toUrl('./overlimitevent.w')
				},
				"signalevent" : {
					url : require.toUrl('./signalevent.w')
				},
				"login2" : {
					url : require.toUrl('./login2.w')
				},
				"contact" : {
					url : require.toUrl('./contact.w')
				},
				"electricData" : {
					url : require.toUrl('./electricData.w')
				},
				"safeEnergy": {
					url : require.toUrl('./safeEnergy.w')
				},
				"safeDetails": {
					url : require.toUrl('./safeDetails.w')
				},
				"video": {
					url : require.toUrl('./video.w')
				}
			}
		});

	};
	var ipAdress;
	Model.prototype.modelLoad = function(event){
		var ua = navigator.userAgent.toLowerCase();
		if(/iphone|ipad|ipod/.test(ua)){
			$(".iosapp").css("top","20px");
		}
	
		justep.Shell.userType = justep.Bind.observable();
		justep.Shell.userName = justep.Bind.observable();
		var userLocal = (localStorage.getItem("userUUID")&&JSON.parse(localStorage.getItem("userUUID"))) || null;
		if(userLocal){
			justep.Shell.showPage("mainpage");
			
		}else{
			this.comp("windowDialog1").open();
		}
	};


	return Model;
});
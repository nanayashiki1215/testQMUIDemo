define(function(require){
	var $ = require("jquery");
	var justep = require("$UI/system/lib/justep");
	require("$UI/system/lib/cordova/cordova");
	require('./js/md5');
	var jpushInstance = require("./jpush");
	var Model = function(){
		this.callParent();
	};

	var oldIp;
	var ipLocal = (localStorage.getItem("ipAdress")) || null;

	Model.prototype.loginBtnClick = function(event){
		var ipAdress = this.comp("ipAdress").val();
		var username = this.comp("username").val();
		var password = this.comp("password").val();
		var passwordMD5 = MD5(password);
		localStorage.setItem("ipAdress",ipAdress);
		var url = "http://"+ipAdress+"/SubstationOperation/rest/app/applogin"
		var userdata = this.comp("userdata");
		var windowReceiver = this.comp("windowReceiver1");
		
		$.ajax({
			type : "get",
			async : false,
			data : {
				"Username" : username,
				"Password" : passwordMD5
			},
			url : url,
			cache : false,
			dataType : "jsonp",
			jsonp : "Callback",
			jsonpCallback : "successCallback",
			success : function(success) {
				userdata.clear();
				userdata.loadData(success);
				var userid;
				if (userdata.count() > 0) {
					userid = userdata.getFirstRow().getID();
					var user = {
						username : username,
						userid : userid
					};
					localStorage.setItem("userUUID", JSON.stringify(user));
					windowReceiver.windowEnsure();
					justep.Shell.showPage("mainpage");		
				} else {
					justep.Util.hint("用户名密码错误");
				}
			}
		});
		
	};

	Model.prototype.modelLoad = function(event){
		if(ipLocal){
			ipAdress = ipLocal;
			oldIp = this.comp("ipAdress").val(ipAdress)
		}else{
			ipAdress = this.comp("ipAdress").val();
		}
	};

	return Model;
});
define(function(require) {
	var $ = require('jquery');
	var justep = require("$UI/system/lib/justep");
	require("cordova!cordova-plugin-device");
	var JPushInstance = function() {
		if (window.plugins && window.plugins.jPushPlugin) {
			document.addEventListener("deviceready", this.onDeviceReady.bind(this), false);
			document.addEventListener("jpush.openNotification", this.onOpenNotification.bind(this), false);
			document.addEventListener("jpush.receiveNotification", this.onReceiveNotification.bind(this), false);
			document.addEventListener("jpush.receiveMessage", this.onReceiveMessage.bind(this), false);
		}
	};
	
	//hcr 解决第一次获取失败的问题
	JPushInstance.prototype.getRegistrationID = function(){
		 var dtd = $.Deferred();
		 if (this.registrationID){
			 dtd.resolve(this.registrationID);
		 }else{
			 if (window.plugins && window.plugins.jPushPlugin){
				 window.plugins.jPushPlugin.getRegistrationID(function(registrationID) {
					 self.registrationID = registrationID;
					 if (self.registrationID){
						 dtd.resolve(self.registrationID);	 
					 }else{
						 dtd.reject();
					 }
				 });
			 }else{
				 dtd.reject();
			 }
		 }
		 return dtd.promise();
	};
	

	JPushInstance.prototype.onDeviceReady = function() {
		var self = this;
		window.plugins.jPushPlugin.init();
		window.plugins.jPushPlugin.getRegistrationID(function(registrationID) {
			self.registrationID = registrationID;
		});
		if (device.platform == "Android") {
			window.plugins.jPushPlugin.setDebugMode(false);
			window.plugins.jPushPlugin.setApplicationIconBadgeNumber(0);
		} else {
			window.plugins.jPushPlugin.setDebugMode(false);
			window.plugins.jPushPlugin.setApplicationIconBadgeNumber(0);
		}
	};

	JPushInstance.prototype.onOpenNotification = function(event) {
		var alertContent;
		if (device.platform == "Android") {
			alertContent = window.plugins.jPushPlugin.openNotification.alert;
		} else {
			alertContent = event.aps.alert;
		}
		window.plugins.jPushPlugin.setApplicationIconBadgeNumber(0);
	};

	JPushInstance.prototype.onReceiveNotification = function(event) {
		var alertContent;
        if(device.platform == "Android"){
        	alertContent = window.plugins.jPushPlugin.receiveNotification.alert;
        }else{
        	alertContent   = event.aps.alert;
        }
        window.plugins.jPushPlugin.setApplicationIconBadgeNumber(0);
		justep.Util.hint(alertContent);
	};

	JPushInstance.prototype.onReceiveMessage = function() {
		var message;
        if(device.platform == "Android"){
       		 message = window.plugins.jPushPlugin.receiveMessage.message;
        }else{
              message   = event.content;
        }
        window.plugins.jPushPlugin.setApplicationIconBadgeNumber(0);
		justep.Util.hint(message);
	};

	return new JPushInstance();
});
define(function(require) {
	var $ = require("jquery");
	var justep = require("$UI/system/lib/justep");
	require("cordova!phonegap-nfc");
	var Model = function() {
		this.callParent();
	};
	var excutedata;
	var subid;
	var planid;
	var subname;
	var address;
	var completetime;
	var starttime;
	var start;
	var over;
	var result;
	var Result;
	var ipAdress;
	Model.prototype.modelParamsReceive = function(event) {
		subname = $(this.getElementByXid('subname'));
		address = $(this.getElementByXid('address'));
		completetime = $(this.getElementByXid('completetime'));
		starttime = $(this.getElementByXid('starttime'));
		excutedata = this.comp("excutedata");
		start = this.comp("start");
		over = this.comp("over");
		result = this.comp("result");
		planid = event.params.planid;
		
		ipAdress = localStorage.getItem("ipAdress");
		var url = "http://" + ipAdress + "/SubstationOperation/rest/app/selectplaninfoonapp";
		$.ajax({
			type : "get",
			async : false,
			data : "Planid=" + planid,
			url : url,
			cache : false,
			dataType : "jsonp",
			jsonp : "Callback",
			jsonpCallback : "successCallback",
			success : function(success) {
				excutedata.clear();
				excutedata.loadData(success);
				subid = excutedata.getFirstRow().val('subid');
				subname.text(excutedata.getFirstRow().val('subname'));
				address.text(excutedata.getFirstRow().val('address'));
				completetime.text(excutedata.getFirstRow().val('completetime'));
				if (excutedata.getFirstRow().val('starttime') == 'null' || excutedata.getFirstRow().val('starttime') == null) {
					starttime.text('计划未开始');
				} else {
					starttime.text(excutedata.getFirstRow().val('starttime').substring(0, 19));
					start.setCSS({
						"background" : "#b5b5b6"
					});
					start.set({
						"disabled" : true
					});
					over.setCSS({
						"background" : "#FF6C1F"
					});
					over.set({
						"disabled" : false
					});
					result.set({
						"disabled" : false
					});
				}
			}
		});
	};
	Model.prototype.startClick = function(event) {
		this.comp('startdialog').show($('.Yes').text("否"), $('.No').text("是"));
	};

	Model.prototype.overClick = function(event) {
		this.comp("enddialog").show($('.Yes').text("否"), $('.No').text("是"));
	};

	Model.prototype.startdialogOK = function(event) {
		// $.ajax({
		// type : "get",
		// async : false,
		// data : "Planid=" + planid,
		// url :
		// "http://www.acrelcloud.cn/SubstationOperation/rest/app/planstart",
		// cache : false,
		// dataType : "jsonp",
		// jsonp : "Callback",
		// jsonpCallback : "successCallback",
		// success : function(success) {
		// nfc.removeNdefListener(myNfcListener,null,null);
		// starttime.text(success);
		// start.setCSS({
		// "background" : "#b5b5b6"
		// });
		// start.set({
		// "disabled" : true
		// });
		// over.setCSS({
		// "background" : "#FF6C1F"
		// });
		// over.set({
		// "disabled" : false
		// });
		// result.set({
		// "disabled" : false
		// });
		// justep.Util.hint("任务开始执行！");
		// }
		// });
		nfc.addNdefListener(myNfcListener, null, failure);
	};

	Model.prototype.modelActive = function(event) {
		subname = $(this.getElementByXid('subname'));
		address = $(this.getElementByXid('address'));
		completetime = $(this.getElementByXid('completetime'));
		starttime = $(this.getElementByXid('starttime'));
		excutedata = this.comp("excutedata");
		start = this.comp("start");
		over = this.comp("over");
		result = this.comp("result");
		planid = event.params.planid;
		
		var url = "http://" + ipAdress + "/SubstationOperation/rest/app/selectplaninfoonapp";
		$.ajax({
			type : "get",
			async : false,
			data : "Planid=" + planid,
			url : url,
			cache : false,
			dataType : "jsonp",
			jsonp : "Callback",
			jsonpCallback : "successCallback",
			success : function(success) {
				excutedata.clear();
				excutedata.loadData(success);
				subname.text(excutedata.getFirstRow().val('subname'));
				address.text(excutedata.getFirstRow().val('address'));
				completetime.text(excutedata.getFirstRow().val('completetime'));
				if (excutedata.getFirstRow().val('starttime') == 'null' || excutedata.getFirstRow().val('starttime') == null) {
					starttime.text('计划未开始');
				} else {
					starttime.text(excutedata.getFirstRow().val('starttime').substring(0, 19));
					start.setCSS({
						"background" : "#b5b5b6"
					});
					start.set({
						"disabled" : true
					});
					over.setCSS({
						"background" : "#FF6C1F"
					});
					over.set({
						"disabled" : false
					});
					result.set({
						"disabled" : false
					});
				}
			}
		});
	};

	Model.prototype.enddialogOK = function(event) {
		Result = this.comp("result").val();
		var url = "http://" + ipAdress + "/SubstationOperation/rest/app/planend";
		$.ajax({
			type : "get",
			async : false,
			data : "Planid=" + planid + "&Result=" + Result,
			url : url,
			cache : false,
			dataType : "jsonp",
			jsonp : "Callback",
			jsonpCallback : "successCallback",
			success : function(success) {
				justep.Shell.closePage();
				justep.Util.hint("任务执行完成！");
			}
		});
	};

	Model.prototype.li1Click = function(event) {
		justep.Shell.closeAllOpendedPages();
	};

	function myNfcListener(NfcEvent) {
		var load = NfcEvent.tag.ndefMessage;
		var payload = load[0].payload;
		var text = bin2String(payload);
		if (text == subid) {
			var url = "http://" + ipAdress + "/SubstationOperation/rest/app/planstart"; 
			$.ajax({
				type : "get",
				async : false,
				data : "Planid=" + planid,
				url : url,
				cache : false,
				dataType : "jsonp",
				jsonp : "Callback",
				jsonpCallback : "successCallback",
				success : function(success) {
					nfc.removeNdefListener(myNfcListener, null, null);
					starttime.text(success);
					start.setCSS({
						"background" : "#b5b5b6"
					});
					start.set({
						"disabled" : true
					});
					over.setCSS({
						"background" : "#FF6C1F"
					});
					over.set({
						"disabled" : false
					});
					result.set({
						"disabled" : false
					});
					justep.Util.hint("任务开始执行！");

				}
			});
		} else {
			justep.Util.hint("变电所信息有误，请扫描正确的变电所nfc！");
			nfc.removeNdefListener(myNfcListener, null, null);
		}
	}
	function bin2String(array) {
		var CodeLength = array[0];
		return String.fromCharCode.apply(String, array.slice(CodeLength + 1))
	}

	function failure(failed) {
		alert("nfc扫描失败,请检查设备是否开启nfc，开启后再次扫描！");
	}
	Model.prototype.li2Click = function(event) {
		justep.Shell.showPage("alarm");
	};

	Model.prototype.startdialogNo = function(event) {

	};

	Model.prototype.enddialogNo = function(event) {

	};

	return Model;
});
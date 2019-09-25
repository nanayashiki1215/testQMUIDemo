define(function(require) {
	var $ = require("jquery");
	var justep = require("$UI/system/lib/justep");
	//require('./js/jquery-2.0.3.min');
	require('./js/bootstrap-select');
	require('./js/main');
	require('./js/bootstrap.min');
	
	var Model = function() {
		this.callParent();

	};
	
	Model.prototype.button1Click = function(event) {
		this.comp("windowReceiver1").windowEnsure();
	};
	var groupid;
	var planid;
	var deadline;
	var ipAdress;
	Model.prototype.windowReceiver1Receive = function(event) {
		
		groupid = event.data.groupid;
		planid = event.data.planid;
		deadline = event.data.deadline;
		this.comp("datetime").val(deadline);
		
		ipAdress = localStorage.getItem("ipAdress");
		var url = "http://"+ipAdress+"/SubstationOperation/rest/app/selectuserforgroup";
		
		$.ajax({
			type : "get",
			async : false,
			data : "Groupid=" + groupid,
			url : url,
			cache : false,
			dataType : "jsonp",
			jsonp : "Callback",
			jsonpCallback : "successCallback",
			success : function(data) {
				
				for (var i = 0; i < data.length; i++) {
					$('#select').append("<option value='" + data[i].user.fUserid + "'>" + data[i].user.fLoginname + "</option>");
				}
				$('#select .selectpicker').selectpicker('refresh');
				$('#select').selectpicker('render');				
			},
			error : function(error) {
				alert("请求数据出错！");
			}
		});
		
	};
	Model.prototype.button2Click = function(event) {
		var Completetime = this.comp("datetime").val();
		var windowReceiver = this.comp("windowReceiver1");
		var span = $("#alert");
		var select = $('#select').val();
		if (select == null) {
			$("#select").css("border-color", "red");
			span.html("巡检人不能为空");
		} else {
			var jsonData = "Planid=" + planid + "&Select=" + select + "&Completetime=" + Completetime;
			var url = "http://"+ipAdress+"/SubstationOperation/rest/app/appassignplan";
			$.ajax({
				type : "get",
				async : false,
				data : jsonData,
				url : url,
				cache : false,
				dataType : "jsonp",
				jsonp : "Callback",
				jsonpCallback : "successCallback",
				success : function(result) {
					if (result == "success") {
						windowReceiver.windowEnsure();
					}
				}
			});
		}

	};

	return Model;
});
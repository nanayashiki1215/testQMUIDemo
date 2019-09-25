define(function(require){
	var $ = require("jquery");
	var justep = require("$UI/system/lib/justep");
	require('js/ezuikit');
	
	var Model = function(){
		this.callParent();
	};
	
	var userid;
	var subid;
	var ipAdress;
	var subdata;

	Model.prototype.modelLoad = function(event){
		var ua = navigator.userAgent.toLowerCase();
		if(/iphone|ipad|ipod/.test(ua)){
			$(".subName").css("margin-top","70px");
		}
	
		subdata = this.comp("subdata");
		userid = JSON.parse(localStorage.getItem("userUUID")).userid;
		var subName = $(this.getElementByXid("subName"));
		ipAdress = localStorage.getItem("ipAdress");
		var url = "http://" + ipAdress + "/SubstationOperation/rest/app/selectsubstationinfo";
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
				subdata.clear();
				if (success !== ''){
					subdata.loadData(success.list);
				}
				$("input").attr('placeholder','选择变配电站');
				subName.text("变配电站："+subdata.getFirstRow().val("f_SubName"));
				subid = subdata.getFirstRow().getID();
				localStorage.setItem("subid",subid);
				$("#iframe2").attr("src","../app/VideoPage.html");
			},
			error:function(e){
				console.log("error",e);
				return;
			}
		})
	};

	Model.prototype.gridSelect2UpdateValue = function(event){
		var subid = subdata.getValue("f_SubID");
		var subName = $(this.getElementByXid("subName"));
		var name = subdata.getValue("f_SubName");
		subName.text("变配电站："+name);
		localStorage.setItem("subid",subid);
		var newSrc = $("#iframe2")[0].src;
		$("#iframe2")[0].src = newSrc;
	};

	return Model;
});
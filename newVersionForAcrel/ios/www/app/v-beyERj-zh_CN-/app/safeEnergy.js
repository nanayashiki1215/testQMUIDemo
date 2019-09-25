define(function(require){
	var $ = require("jquery");
	var justep = require("$UI/system/lib/justep");
	
	var Model = function(){
		this.callParent();
	};
	var userid;
	var subid;
	var select;
	var ipAdress;
	var subdata;
	var tempdata;
	
	Model.prototype.modelLoad = function(event){
		var ua = navigator.userAgent.toLowerCase();
		if(/iphone|ipad|ipod/.test(ua)){
			$(".subName").css("margin-top","70px");
		}
		subdata = this.comp("subdata");
		tempdata = this.comp("tempdata");
		select=$(this.getElementByXid("select"));
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
				var url2 = "http://" + ipAdress + "/SubstationOperation/rest/app/getTempABCResult";
				$.ajax({
					type : "get",
					async : false,
					data : "fSubid=" + subid + "&pageNo=" + 1 + "&pageSize=",
					url : url2,
					cache : false,
					dataType : "jsonp",
					jsonp : "Callback",
					jsonpCallback : "successCallback",
					success : function(data) {
						tempdata.clear();
						if (data !== ''){
							tempdata.loadData(data.list);		
						}
					},
					error:function(e){
						console.log("error",e);
						return;
					}
				});
			},
			error:function(e){
				console.log("error",e);
				return;
			}
		})
	};

	Model.prototype.tempBtnClick = function(event){
		var params = event.bindingContext.$object.toJson({
			format : 'simple'
		})
		
		this.comp("windowDialog2").open({
				data : params
			});
	};
	
	Model.prototype.button5Click = function(event){
		this.comp("input5").val('');
		var url = "http://" + ipAdress + "/SubstationOperation/rest/app/selectsubstationinfo";
		$.ajax({
			type : "get",
			async : false,
			data : "Userid=" + userid+"&search=",
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
			}
		})
	};

	Model.prototype.gridSelect2UpdateValue = function(event){
		var subid = subdata.getValue("f_SubID");
		var subName = $(this.getElementByXid("subName"));
		var name = subdata.getValue("f_SubName");
		subName.text("变配电站："+name);
		var url2 = "http://" + ipAdress + "/SubstationOperation/rest/app/getTempABCResult";
		$.ajax({
			type : "get",  
			async : false,
			data : "fSubid=" + subid + "&pageNo=" + 1 + "&pageSize=",
			url : url2,
			cache : false,
			dataType : "jsonp",
			jsonp : "Callback",
			jsonpCallback : "successCallback",
			success : function(data) {
				tempdata.clear();
				if (data !== ''){
					tempdata.loadData(data.list);
				}
			},
		});
	};

	return Model;
});
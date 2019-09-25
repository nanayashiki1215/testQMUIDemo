define(function(require) {
	var $ = require("jquery");
	var justep = require("$UI/system/lib/justep");
	require("js/ezuikit");
	var Model = function() {
		this.callParent();
	};

	Model.prototype.li1Click = function(event) {
		justep.Shell.closeAllOpendedPages();
	};
	Model.prototype.li2Click = function(event) {
		justep.Shell.showPage("alarm");
	};
	var userid;
	var ipAdress;
	Model.prototype.modelLoad = function(event) {
		var subname=$(this.getElementByXid("subname"));
		var subdata = this.comp("subdata");
		var eventdata = this.comp("eventdata");
		var eventtypedata = this.comp("eventtypedata");
		var subid;
		var startdate = justep.Date.toString(new Date(new Date().getTime() - 24 * 60 * 60 * 1000), 'yyyy-MM-dd');
		var enddate = justep.Date.toString(new Date(), 'yyyy-MM-dd');
		this.comp("startdate").val(startdate);
		this.comp("enddate").val(enddate);
		userid = JSON.parse(localStorage.getItem("userUUID")).userid;
		var eventtype = this.comp("eventtype");
		var subID = this.comp("subid");
		
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
				if (success !== '')
					subdata.loadData(success.list);
				subid = subdata.getFirstRow().getID();
				eventtype.val(eventtypedata.getFirstRow().getID());
				subID.val(subdata.getFirstRow().getID());
				//得到当前行id的subname值
				subname.text(subdata.getFirstRow().val("f_SubName"));
				var url2 = "http://" + ipAdress + "/SubstationOperation/rest/app/getoverlimitevent";
				$.ajax({
					type : "get",
					async : false,
					data : "Subid=" + subid + "&StartDate=" + startdate + "&EndDate=" + enddate,
					url : url2,
					cache : false,
					dataType : "jsonp",
					jsonp : "Callback",
					jsonpCallback : "successCallback",
					success : function(success) {
						eventdata.clear();
						if (success !== '')
							eventdata.loadData(success);
					}
				});
			}
		});

	};
	Model.prototype.button1Click = function(event) {

		this.comp("wing1").showLeft();
	};
	Model.prototype.button3Click = function(event) {
		var eventparams = event.bindingContext.$object.toJson({
			format : 'simple'
		});
		if (eventparams.limitvalue == null)
			this.comp("windowDialog1").open({
				data : eventparams
			});
		else {
			this.comp("windowDialog2").open({
				data : eventparams
			});
		}
	};
	Model.prototype.div5Click = function(event) {
		this.comp("windowDialog1").close();
		this.comp("windowDialog2").close();
	};

	Model.prototype.button2Click = function(event) {
		var subid = this.comp("subid").val();
		var eventtype = this.comp("eventtype").val();
		var startdate = this.comp("startdate").val();
		var enddate = this.comp("enddate").val();
		var eventdata = this.comp("eventdata");
		var subdata=this.comp("subdata");
		var subname = $(this.getElementByXid("subname"));
		subname.text(subdata.getRowByID(subid).val("subname"));
		if (eventtype == 1) {// 越限事件
			var url3 = "http://" + ipAdress + "/SubstationOperation/rest/app/getoverlimitevent";
			$.ajax({
				type : "get",
				async : false,
				data : "Subid=" + subid + "&StartDate=" + startdate + "&EndDate=" + enddate,
				url : url3,
				cache : false,
				dataType : "jsonp",
				jsonp : "Callback",
				jsonpCallback : "successCallback",
				success : function(success) {
					eventdata.clear();
					if (success !== '')
						eventdata.loadData(success);
				}
			});
		} else if (eventtype == 2) {// 遥信事件
			var url4 = "http://" + ipAdress + "/SubstationOperation/rest/app/getsignalevent";
			$.ajax({
				type : "get",
				async : false,
				data : "Subid=" + subid + "&StartDate=" + startdate + "&EndDate=" + enddate,
				url : url4,
				cache : false,
				dataType : "jsonp",
				jsonp : "Callback",
				jsonpCallback : "successCallback",
				success : function(success) {
					eventdata.clear();
					if (success !== '')
						eventdata.loadData(success);
				}
			});
		}

		this.comp("wing1").hideLeft();

	};
	Model.prototype.content1Click = function(event) {
		this.comp("wing1").hideLeft();
	};
	Model.prototype.scrollView1PullDown = function(event){
		var subid = this.comp("subid").val();
		var eventtype = this.comp("eventtype").val();
		var startdate = this.comp("startdate").val();
		var enddate = this.comp("enddate").val();
		var eventdata = this.comp("eventdata");
		var subdata=this.comp("subdata");
		var subname = $(this.getElementByXid("subname"));
		subname.text(subdata.getRowByID(subid).val("subname"));
		if (eventtype == 1) {// 越限事件
			var url5 = "http://" + ipAdress + "/SubstationOperation/rest/app/getoverlimitevent";
			$.ajax({
				type : "get",
				async : false,
				data : "Subid=" + subid + "&StartDate=" + startdate + "&EndDate=" + enddate,
				url : url5,
				cache : false,
				dataType : "jsonp",
				jsonp : "Callback",
				jsonpCallback : "successCallback",
				success : function(success) {
					eventdata.clear();
					if (success !== '')
						eventdata.loadData(success);
				}
			});
		} else if (eventtype == 2) {// 遥信事件
			var url6 = "http://" + ipAdress + "/SubstationOperation/rest/app/getsignalevent";
			$.ajax({
				type : "get",
				async : false,
				data : "Subid=" + subid + "&StartDate=" + startdate + "&EndDate=" + enddate,
				url : url6,
				cache : false,
				dataType : "jsonp",
				jsonp : "Callback",
				jsonpCallback : "successCallback",
				success : function(success) {
					eventdata.clear();
					if (success !== '')
						eventdata.loadData(success);
				}
			});
		}
		
	};
	return Model;
});
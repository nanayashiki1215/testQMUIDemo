define(function(require){
	var $ = require("jquery");
	var justep = require("$UI/system/lib/justep");
	require("js/echarts-all");
	var Model = function(){
		this.callParent();
	};

	var subid;
	var f_MeterCode;
	var ipAdress = localStorage.getItem("ipAdress");
	var subdata;
	var f_MeterName;

	Model.prototype.windowReceiver = function(event){
		$("#domTable").addClass('display');
		$("#domEcharts").css('display','block');
		$("#button3").css('background','#f39800');
		$("#button4").css('background','#3db3ff');
		subdata = this.comp("subdata");
		subid = event.data.f_SubID;
		f_MeterCode = event.data.f_MeterCode;
		f_MeterName = event.data.f_MeterName;
		$("#span2").html(f_MeterName);
		var date = justep.Date.toString(new Date(), 'yyyy-MM-dd');
		this.comp("startdate").val(date);
		var start=date+" 00:00:00";
		var end=date+" 23:59:59"
		var params="fSubid="+subid + "&F_MeterCode=" +f_MeterCode+ "&pageNo="+1 + "&pageSize="+ "&startDate="+start + "&endDate="+end
		data(params);
	
	};
	
	Model.prototype.button1Click = function(event){
		var newdate = this.comp("startdate").val();
		var date = justep.Date.toString(new Date(new Date(newdate).getTime() - 24 * 60 * 60 * 1000), 'yyyy-MM-dd');
		this.comp("startdate").val(date);
		ipAdress = localStorage.getItem("ipAdress");
		var start=date+" 00:00:00";
		var end=date+" 23:59:59"
		var params="fSubid="+subid + "&F_MeterCode=" +f_MeterCode+ "&pageNo="+1 + "&pageSize="+ "&startDate="+start + "&endDate="+end
		data(params);
	};

	Model.prototype.button2Click = function(event){
		var newdate = this.comp("startdate").val();
		var date = justep.Date.toString(new Date(new Date(newdate).getTime() + 24 * 60 * 60 * 1000), 'yyyy-MM-dd');
		this.comp("startdate").val(date);
		var start=date+" 00:00:00";
		var end=date+" 23:59:59";
		var params="fSubid="+subid + "&F_MeterCode=" +f_MeterCode+ "&pageNo="+1 + "&pageSize=" + "&startDate="+start + "&endDate="+end
		data(params);
	};

	function data(params){
		var url = "http://"+ipAdress+"/SubstationOperation/rest/app/getTempABCResultHistoryList";
		$.ajax({
			type : "get",
			async : false,
			data : params,
			url : url,
			cache : false,
			dataType : "jsonp",
			jsonp : "Callback",
			jsonpCallback : "successCallback",
			success : function(receiveData) {
				subdata.clear();
				if (receiveData!=null){
					var listData=[];
					if(receiveData.list.length>0){
						$.each(receiveData.list,function(key,val){
							var row={};
							row.f_CollectTime=val.f_CollectTime.substring(0,16);
							row.f_MeterName=val.f_MeterName;
							row.f_TempA=val.f_TempA;
							row.f_TempB=val.f_TempB;
							row.f_TempC=val.f_TempC;
							listData.push(row);
						})
					}
					subdata.loadData(listData);
				}
				gengerateData(receiveData.list)
			}
		});
	}
	
		function gengerateData(data){	
			var time=[];
			var f_TempA=[];
			var f_TempB=[];
			var f_TempC=[];
			
			if(data.length>0){
				$.each(data, function(key, val) {
				time.push(val.f_CollectTime.substring(11,16));
				f_TempA.push(val.f_TempA);
				f_TempB.push(val.f_TempB);
				f_TempC.push(val.f_TempC);
				});
			}
			showChart(time,f_TempA,f_TempB,f_TempC)
		}
			
		var option;
		function showChart(time,dataA,dataB,dataC){
			option = {
				tooltip : {
					trigger : 'axis'
				},
				legend : {
					data : ['温度A','温度B','温度C'],
					x:'left',
				},
				grid : {
					x : 25,
					y : 40,
					x2 : 5,
					y2 : 20,
					borderWidth : 1
				},
				toolbox : {
					show : true,
					feature : {
						magicType : {
							show : true,
							type : [ 'line', 'bar' ]
						},
						restore : {
							show : true
						},
					}
				},
				calculable : true,
				xAxis : [ {
					data :time,
					}],
				yAxis : [ {
					type:'value',
					scale:true,
					splitArea : {
						show : true
					}
				} ],
				series : [ {
					name : '温度A',
					type : 'line',
					data : dataA
				}, {
					name : '温度B',
					type : 'line',
					data : dataB
				},{
					name : '温度C',
					type : 'line',
					data : dataC
				} ]
			};
			var myChart = echarts.init(document.getElementById("domEcharts"));
			myChart.setOption(option);
		}


	Model.prototype.button3Click = function(event){
		$("#domEcharts").css('display','block');
		$("#domTable").addClass('display');
		$("#button3").css('background','#f39800');
		$("#button4").css('background','#3db3ff');
		var myChart = echarts.init(document.getElementById("domEcharts"));
		myChart.setOption(option);
	};


	Model.prototype.button4Click = function(event){
		$("#domEcharts").css('display','none');
		$("#domTable").removeClass('display');
		$("#button4").css('background','#f39800');
		$("#button3").css('background','#3db3ff');
	};
	return Model;
});
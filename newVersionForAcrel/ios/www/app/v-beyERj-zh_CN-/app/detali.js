define(function(require) {
	var $ = require("jquery");
	var justep = require("$UI/system/lib/justep");
	require("js/echarts-all");
	var Model = function() {
		this.callParent();
	};
	var subid;
	var ipAdress;
	Model.prototype.modelParamsReceive = function(event) {
		ipAdress = localStorage.getItem("ipAdress");
		var url = "http://"+ipAdress+"/SubstationOperation/rest/app/getSubInfo";
		subid = event.params.subid;
		$.ajax({
			type : "get",
			async : false,
			data : "Subid=" + subid,
			url : url,
			cache : false,
			dataType : "jsonp",
			jsonp : "Callback",
			jsonpCallback : "successCallback",
			success : function(data) {
			
				showSubstationInfo(data.SubstationStatus.SubstationStatus);
				// 获取运行状态
				showRunningInfo(data.SubstationStatus.RunningStatus);
				// 当日事件记录
				showDayInfo(data.SubstationStatus);
				// 用电概况
				showCompareData(data.EHCAndES.EnergyStatus);
				
				var obj = showCharLine(data.EHCAndES.EnergyHourCurve);
		
				generateChart(obj.today, obj.yesterday);
			}
		});

		// 显示变电所基本信息
		function showSubstationInfo(data) {
			$("#fsubName").html(data.SubstationInfo.fSubname);
			if(data.SubstationInfo.fVoltagestep<1){
				$("#level").html(data.SubstationInfo.fVoltagestep.substring(0, data.SubstationInfo.fVoltagestep.length - 1) + "<span>kV</span>");
			}else{
				$("#level").html(data.SubstationInfo.fVoltagestep.substring(0, data.SubstationInfo.fVoltagestep.length - 3) + "<span>kV</span>");
			}
			$("#number").html(data.SubstationInfo.fTransformernum + "<span>台</span>");
			$("#install").html(data.SubstationInfo.fInstalledcapacity.substring(0, data.SubstationInfo.fInstalledcapacity.length - 3) + "<span>kVA</span>");
			$("#operation").html(data.SubstationInfo.fApplycapacity.substring(0, data.SubstationInfo.fApplycapacity.length - 3) + "<span>kVA</span>");
			$("#observe").html(data.SubMeterNums + "<span>个</span>");
		}

		// 显示变电所运行状态
		function showRunningInfo(data) {
			var fP = "--";
			var fQ = "--";
			var fTemp = "--";
			var fHumidity = "--";
			var fTime = "--";
			if (data.FPFQ !== null) {
				if (data.FPFQ.fP !== null)
					fP = data.FPFQ.fP.split(".");
					fP = fP[0] + "." + fP[1].substring(0,1); 
				if (data.FPFQ.fQ !== null)
					fQ = data.FPFQ.fQ.split(".");
					fQ = fQ[0] + "." + fQ[1].substring(0,1);
				if (data.FPFQ.fCollecttime !== null)
					fTime = data.FPFQ.fCollecttime.substring(0, 19);
			}
			if (data.FTempFHumidity !== null) {
				if (data.FTempFHumidity.fTemp !== null)
					fTemp = data.FTempFHumidity.fTemp.split(".");
					fTemp = fTemp[0] + "." + fTemp[1].substring(0,1);
				if (data.FTempFHumidity.fHumidity !== null)
					fHumidity = data.FTempFHumidity.fHumidity.split(".");
					fHumidity = fHumidity[0] + "." + fHumidity[1].substring(0,1);
				if (data.FTempFHumidity.fCollecttime !== null && fTime == "--")
					fTime = data.FTempFHumidity.fCollecttime.substring(0, 19);
			}
			$("#perform").html(fP + "<span>kW</span>");
			$("#idle").html(fQ + "<span>kVar</span>");
			$("#temperature").html(fTemp + "<span>℃</span>");
			$("#humidity").html(fHumidity + "<span>%</span>");
			$("#reset-time").html("更新时间:" + fTime);
		}
		// 显示当日用电事件记录
		function showDayInfo(data) {
			$("#limit").html(data.DayReport.OverLimitTimes + "<span>次</span>");
			$("#deflection").html(data.DayReport.SwitchingTimes + "<span>次</span>");
			var newData=data.SubstationStatus.SubstationInfo;
			var smog = "<span>无</span>";
			var waterIn = "<span>无</span>";
			if(newData.fSmog!=undefined){
				if(newData.fSmog=="0"){
					smog = "<span>正常</span>";
				}else{
					smog = "<span>异常</span>";
				}
			}
			if(newData.fWaterin!=undefined){
				if(newData.fWaterin=="0"){
					waterIn = "<span>正常</span>";
				}else{
					waterIn = "<span>异常</span>";
				}
			}
			$("#water").html(smog);
			$("#smoke").html(waterIn);
		}
		// 显示用电概况
		function showCompareData(data) {

			if (data.TodayTotalValue !== null)
				$("#todayTotal").html(data.TodayTotalValue[0].fSumvalue.substring(0, data.TodayTotalValue[0].fSumvalue.length - 3) + " kW·h");

			if (data.YesterdayTotalValue !== null)
				$("#yesterdayTotal").html(data.YesterdayTotalValue[0].fSumvalue.substring(0, data.YesterdayTotalValue[0].fSumvalue.length - 3) + " kW·h");

			if (data.TodayTotalValue !== null && data.YesterdayTotalValue !== null) {
				var diff = ((data.TodayTotalValue[0].fSumvalue - data.YesterdayTotalValue[0].fSumvalue) * 100 / data.YesterdayTotalValue[0].fSumvalue).toFixed(2);
				if (diff >= 0)
					$("#difference").html(diff + "%" + '<img src="image/up.png">');
				else
					$("#difference").html(diff + "%" + '<img src="image/down.png">');
			}

			if (data.MaxValueInfoOfOneDay !== null) {
				if (data.MaxValueTimes !== 0)
					$("#maxTime").html(data.MaxValueTimes);
				else
					$("#maxTime").html("--");
				if (data.MaxValueInfoOfOneDay !== 0)
					$("#levelPower").html(data.MaxValueInfoOfOneDay + " kW");
				else
					$("#levelPower").html("-- kW");
			} else {
				$("#maxTime").html("--");
				$("#levelPower").html("-- kW");
			}
		}
		function showCharLine(data) {
			var todayValue = new Array(24);
			var yesterdayValue = [];
			if (data.resYesterday !== null) {
				$.each(data.resYesterday, function(key, val) {
					var hour = new Date(val.fStarthour.replace(/-/g, "/"));
					yesterdayValue[hour.getHours()] = val.fHourvalue;
				});
			}
			
			if (data.resToday !== null) {
				$.each(data.resToday, function(key, val) {
					var hour = new Date(val.fStarthour.replace(/-/g, "/"));
					todayValue[hour.getHours()] = val.fHourvalue;
				});
			}
			return {
				"today" : todayValue,
				"yesterday" : yesterdayValue
			};
		}
		function generateChart(today, yesterday) {
			var option = {
				tooltip : {
					trigger : 'axis'
				},
				legend : {
					data : [ '昨日', '今日' ]
				},
				grid : {
					x : 25,
					y : 45,
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
					type : 'category',
					data : [ '0时', '1时', '2时', '3时', '4时', '5时', '6时', '7时', '8时', '9时', '10时', '11时', '12时', '13时', '14时', '15时', '16时', '17时', '18时', '19时', '20时', '21时', '22时', '23时' ]
				} ],
				yAxis : [ {
					type : 'value',
					splitArea : {
						show : true
					}
				} ],
				series : [ {
					name : '昨日',
					type : 'bar',
					data : yesterday
				}, {
					name : '今日',
					type : 'bar',
					data : today
				} ]
			};
			var myChart = echarts.init(document.getElementById("domEcharts"));
			myChart.setOption(option);
		}
	};

	Model.prototype.li1Click = function(event) {
		justep.Shell.closeAllOpendedPages();

	};

	Model.prototype.li2Click = function(event) {
		justep.Shell.showPage("alarm");
	};

	return Model;
});
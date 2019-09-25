define(function(require) {
	var $ = require("jquery");
	var justep = require("$UI/system/lib/justep");
	require('./js/main');
	require('./js/bootstrap.min');
	require('./js/bootstrap-table');

	var Model = function() {
		this.callParent();
	};

	var Substation = {
		DOMOperator : {
			generateTable : function($table, columns, data) {
				
				$table.bootstrapTable({
					striped : true,
					classes : 'table table-border',
					columns : columns,
					data : data
				});
			},
		}
	};
	var ipAdress;
	Model.prototype.modelLoad = function(event) {
		var subname = $(this.getElementByXid("subname"));
		var subdata = this.comp("subdata");
		var subid;
		var startdate = justep.Date.toString(new Date(), 'yyyy-MM-dd');
		this.comp("startdate").val(startdate);
		var userid = JSON.parse(localStorage.getItem("userUUID")).userid;
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
				if (success !== ''){
					subdata.loadData(success.list);
					subid = subdata.getFirstRow().getID();
					subID.val(subdata.getFirstRow().getID());
					subname.text(subdata.getRowByID(subid).val("f_SubName"));	
					var url2 = "http://" + ipAdress + "/SubstationOperation/rest/app/getCircuitList";
					$.ajax({
						type : "get",
						async : false,
						data : "Subid=" + subid,
						url : url2,
						cache : false,
						dataType : "jsonp",
						jsonp : "Callback",
						jsonpCallback : "successCallback",
						success : function(data) {
							for (var i = 0; i < data.length; i++) {
								$('#fCircuitid').append("<option value='" + data[i].fCircuitid + "'>" + data[i].fCircuitname + "</option>");
							}
						},
						error : function(error) {
							alert("请求数据出错！");
						}
					});
				}

			}
		});
	};
	// 变电所change事件
	Model.prototype.subidChange = function(event) {
		var subid = this.comp("subid").val();
		var subdata = this.comp("subdata");
		var subname = $(this.getElementByXid("subname"));
		var select = $('#fCircuitid').html("");
		
		var url3 = "http://" + ipAdress + "/SubstationOperation/rest/app/getCircuitList";
		$.ajax({
			type : "get",
			async : false,
			data : "Subid=" + subid,
			url : url3,
			cache : false,
			dataType : "jsonp",
			jsonp : "Callback",
			jsonpCallback : "successCallback",
			success : function(data) {
				for (var i = 0; i < data.length; i++) {
					$('#fCircuitid').append("<option value='" + data[i].fCircuitid + "'>" + data[i].fCircuitname + "</option>");
				}
			},
			error : function(error) {
				alert("请求数据出错！");
			}
		});
	};
	// 点击查询按钮
	Model.prototype.button2Click = function(event) {
		var userid = JSON.parse(localStorage.getItem("userUUID")).userid;
		var username = JSON.parse(localStorage.getItem("userUUID")).username;
		var subid = this.comp("subid").val();
		var startdate = this.comp("startdate").val();
		var selectType = $("#selectType").val();
		var select = $('#fCircuitid').val();
		var subdata = this.comp("subdata");
		var subname = $(this.getElementByXid("subname"));
		subname.text(subdata.getRowByID(subid).val("f_SubName"));
		var time = this.comp("startdate").val();
		$("#time").html(time);
		var selectText = $("#fCircuitid").find("option:selected").text();
		$("#HLname").html(selectText);
		var params = "username=" + username + "&fCircuitid=" + select + "&time=" + startdate + "&Subid=" + subid + "&EnergyKind=" + selectType;
		
		var url4 = "http://" + ipAdress + "/SubstationOperation/rest/app/getPowerDate";
		$.ajax({
			type : "get",
			async : false,
			data : params,
			url : url4,
			cache : false,
			dataType : "jsonp",
			jsonp : "Callback",
			jsonpCallback : "successCallback",
			success : function(data) {
				if (data !== "") {
					generate(data.powerDate);
				}
				// 参数类别不同生成的表格不同
				function generate(data) {
					var times = [];
					var names = [];
					var series = [];
					var currentList = [];
					if (!data.hasOwnProperty('CircuitValueByDate')) {
						return;
					}

					$.each(data.CircuitValueByDate, function(key, val) {
						if ($.inArray(val.fCollecttime, times) == -1)
							times.push(val.fCollecttime);
						if (currentList.length == 0) {
							names.push(val.fParamcode.substring(1));
							currentList.push({
								name : val.fParamcode.substring(1),
								values : []
							})
						}
						if ($.inArray(val.fParamcode.substring(1), names) != -1) {
							currentList[$.inArray(val.fParamcode.substring(1), names)].values.push({
								time : val.fCollecttime,
								value : val.fParamvalue
							});
						} else {
							names.push(val.fParamcode.substring(1));
							currentList.push({
								name : val.fParamcode.substring(1),
								values : [ {
									time : val.fCollecttime,
									value : val.fParamvalue
								} ]
							});
						}
					});
					$.each(currentList, function(key, val) {
						var datas = [];
						$.each(val.values, function(index, value) {
							var location = $.inArray(value.time, times);
							datas[location] = value.value;
							series.push({
								name : val.name,
								data : datas
							});
						});
					});
					showTable(names, times, series);
				}
				function showTable(names, times, series) {
					var y = $(window).height();
					$("#tableData").html('<table></table');
					$("#tableData>table").attr('data-height', y - 80);
					var columns = [];
					// columns.push({field:'name',title:'回路名称'});
					columns.push({
						field : 'time',
						title : '采集时间'
					});

					$.each(names, function(index, val) {
						columns.push({
							field : val,
							title : val
						});
					});
					var tableRows = [];
					$.each(times, function(key, val) {
						var row = {};
						var time = {};
						var timestamp = val;
						var date = new Date(timestamp);
						var h = date.getHours();
						if (h < 10) {
							h = "0" + h;
						} else {
							h = h;
						}
						m = date.getMinutes() + "0";
						time = h + ":" + m;
						row.time = time; 
						$.each(series, function(index, value) {
							row[value.name] = value.data[key];
						});
						tableRows.push(row);
					});

					$("#tableData>table").width($("#tableData").width());
					$("#tableData>table").height($("#tableData").height());
					Substation.DOMOperator.generateTable($("#tableData>table"), columns, tableRows);
				}
				$("table>thead>tr").css({
					'background-color' : '#3db3ff'
				});
				$("table>tbody>tr").attr("height", "40");
				$("table>tbody tr:last").removeAttr();
			}
		});
		this.comp("wing1").hideLeft();
	};

	Model.prototype.button1Click = function(event) {
		this.comp("wing1").showLeft();
	};
	Model.prototype.content1Click = function(event) {
		this.comp("wing1").hideLeft();
	};

	return Model;
});
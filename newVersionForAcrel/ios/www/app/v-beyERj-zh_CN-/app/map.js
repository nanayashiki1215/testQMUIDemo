define(function(require) {
	var $ = require("jquery");
	var justep = require("$UI/system/lib/justep");

	var Model = function() {
		this.callParent();
	};
	var userid;

	Model.prototype.modelLoad = function(event) {
		userid = JSON.parse(localStorage.getItem("userUUID")).userid;
		var data = null;
		var ipAdress = localStorage.getItem("ipAdress");
		var id = this.getIDByXID("baiducontent");
		var url = "http://"+ipAdress+"/SubstationOperation/rest/app/selectsubstationinfoformap";
		window._baiduInit = function() {
			var map = new BMap.Map(id);
			map.enableScrollWheelZoom(true);// 设置允许鼠标滚轮缩放地图
			/*// 以城市名称为中心
			map.setCurrentCity("上海");
			// 设置允许鼠标滚轮缩放地图
			map.enableScrollWheelZoom(true);

			var bottom_right_control = new BMap.ScaleControl({
				anchor : BMAP_ANCHOR_BOTTOM_RIGHT
			});
			map.addControl(bottom_right_control);
			var top_left_control = new BMap.ScaleControl({
				anchor : BMAP_ANCHOR_TOP_LEFT
			});*/
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
					reversedata(success);
				}
			});
			// 地图展示的变电站的点
			function reversedata(data) {
				map.clearOverlays();
				var pointCenter = new BMap.Point(data[0].f_Longitude, data[0].f_Latitude);
				map.centerAndZoom(pointCenter, 10);
				for (var i = 0; i < data.length; i++) {
					var fSubid = data[i].f_SubID;
					var fLong = data[i].f_Longitude;
					var fLat = data[i].f_Latitude;
					var name = data[i].f_SubName;
					var point = new BMap.Point(parseFloat(fLong), parseFloat(fLat));
					var label = new BMap.Label(name, {
						offset : new BMap.Size(20, -10)
					});
					var marker = new BMap.Marker(point);
					/*var icons = "image/m.png";
					// 显示图标大小
					var icon = new BMap.Icon(icons, new BMap.Size(100, 100)); 
					// 设置标签的图标为自定义图标
					marker.setIcon(icon);*/
					map.addOverlay(marker);
					marker.setLabel(label);
					label.setStyle({
						maxWidth : 'none',
						fontSize : '15px',
						padding : '5px',
						border : 'none',
						color : '#fff',
						background : '#ff8355',
						borderRadius : '5px'
					});
					addClick(fSubid, marker);
					marker.setAnimation(BMAP_ANIMATION_BOUNCE);
				}
			}

			function addClick(subid, marker) {
				marker.addEventListener('click', function(e) {
					var params = {
						"subid" : subid
					};
					justep.Shell.showPage("detali", params);
				});
			}
		};

		require([ 'http://api.map.baidu.com/api?v=4.0&ak=&callback=_baiduInit' ], function() {
			if (window.BMap && window.BMap.Map) {
				window._baiduInit();
			}
		});
	};

	return Model;
});
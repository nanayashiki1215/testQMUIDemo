cordova.define("com.justep.cordova.plugin.baiduMapBase.baiduMap", function(require, exports, module) {
var cordova = require('cordova');
var exec = require('cordova/exec');

var curEvents = null;

var baiduMap = function(){	
};

//地图上标注的颜色
baiduMap.prototype.annotationColor = {
	Red:0,//红色
	Green:1,//绿色
	Purple:2//紫色
};
//操作地图的事件名称
baiduMap.prototype.baiduMapEvent = {
	longPress:"longPress",//长按事件
	viewChange:"viewChange",//地图视角范围发生改变事件
	click:"click",//单击事件
	dbClick:"dbClick"//双击事件	
};

//打开百度地图
baiduMap.prototype.open = function(args,success,error){
	//判断用户是否传入了model
	if(args.model) {
		//当用户传入model，则在model onInactive时保证销毁掉百度地图
		args.model.on('onInactive',baiduMap.prototype.close);
	};
	//监听相关事件
	if (args.events) {
		curEvents = args.events;
		if (args.events.click){
			baiduMap.prototype.addEventListener("click",args.events.click);
		};
		if (args.events.dbClick){
			baiduMap.prototype.addEventListener("dbClick",args.events.dbClick);
		};
		if (args.events.longPress){
			baiduMap.prototype.addEventListener("longPress",args.events.longPress);
		};
		if (args.events.viewChange){
			baiduMap.prototype.addEventListener("viewChange",args.events.viewChange);
		};
	}else{
		curEvents = null;
	}
	exec(success, error, "baiduMap", "open", [args]);
};
//关闭百度地图
baiduMap.prototype.close = function(){
	if(curEvents != null){
		if (curEvents.click){
			baiduMap.prototype.removeEventListener("click",curEvents.click);
		};
		if (curEvents.dbClick){
			baiduMap.prototype.removeEventListener("dbClick",curEvents.dbClick);
		};
		if (curEvents.longPress){
			baiduMap.prototype.removeEventListener("longPress",curEvents.longPress);
		};
		if (curEvents.viewChange){
			baiduMap.prototype.removeEventListener("viewChange",curEvents.viewChange);
		};
	}
	exec(null,null,"baiduMap","close",[]);
};
///监听地图相关事件,用户不必调用此接口
baiduMap.prototype.addEventListener = function(action,callBack){
   if(!document.getElementById('baiduMapNode')){
       this.$baiduMapNode = $("<div class='baiduMap_native' id='baiduMapNode'></div>").appendTo('body');
   }
   this.$baiduMapNode.off(action);
   this.$baiduMapNode.on(action,callBack);
};
//停止监听地图相关事件
baiduMap.prototype.removeEventListener = function(action,callBack) {
    this.$baiduMapNode.off(action,callBack);
};
//当地图相关事件触发后，自动调用此方法
baiduMap.prototype.eventOccur = function(args){
    if(document.getElementById('baiduMapNode')){
       this.$baiduMapNode.trigger(args.action,args);
    } 
};
//重新设置显示区域
baiduMap.prototype.setPosition = function(args){
	exec(null,null,"baiduMap","setPosition",[args]);
};
//获取当前位置经纬度
baiduMap.prototype.getCurrentLocation = function(success,error){
	exec(success,error,"baiduMap","getCurrentLocation",[]);
};
//根据地址信息获取经纬度
baiduMap.prototype.getLocationFromName = function(args,success,error){
	exec(success,error,"baiduMap","getLocationFromName",[args]);
};
//根据经纬度获取地址信息
baiduMap.prototype.getNameFromLocation = function(args,success,error){
	exec(success,error,"baiduMap","getNameFromLocation",[args]);
};
//是否在地图上显示当前位置，并且设置显示的样式
baiduMap.prototype.showCurrentLocation = function(args){
	exec(null,null,"baiduMap","showCurrentLocation",[args]);
};
//设置地图的中心的经纬度
baiduMap.prototype.setCenter = function(args){
	exec(null,null,"baiduMap","setCenter",[args]);
};
//获取地图中心点的经纬度
baiduMap.prototype.getCenter = function(success,error){
	exec(success,error,"baiduMap","getCenter",[]);
};
//设置百度地图缩放等级，此接口自带动画效果
baiduMap.prototype.setZoomLevel = function(args){
	exec(null,null,"baiduMap","setZoomLevel",[args]);
};
//设置百度地图相关属性
baiduMap.prototype.setMapAttr = function(args){
	exec(null,null,"baiduMap","setMapAttr",[args]);
};
//设置百度地图旋转角度，此接口自带动画效果
baiduMap.prototype.setRotation = function(args){
	exec(null,null,"baiduMap","setRotation",[args]);
};
//设置百度地图的俯视角度，此接口自带动画效果
baiduMap.prototype.setOverlook = function(args){
	exec(null,null,"baiduMap","setOverlook",[args]);
};
//设置百度地图的比例尺
baiduMap.prototype.setScaleBar = function(args){
	exec(null,null,"baiduMap","setScaleBar",[args]);
};
//设置百度地图指南针的位置
baiduMap.prototype.setCompass = function(args){
	exec(null,null,"baiduMap","setCompass",[args]);
};
//设置是否显示交通状况
baiduMap.prototype.setTraffic = function(args){
	exec(null,null,"baiduMap","setTraffic",[args]);
};
//设置是否显示城市热力图
baiduMap.prototype.setHeatMap = function(args){
	exec(null,null,"baiduMap","setHeatMap",[args]);
};
//设置是否显示3D楼块效果,地图放大,才会有3D楼快效果,倾斜视角3D效果会更明显
baiduMap.prototype.setBuilding = function(args){
	exec(null,null,"baiduMap","setBuilding",[args]);
};
//设置地图显示范围（矩形区域），此接口自带动画效果
baiduMap.prototype.setRegion = function(args){
	exec(null,null,"baiduMap","setRegion",[args]);
};
//获取地图显示范围(矩形区域)
baiduMap.prototype.getRegion = function(suceess,error){
	exec(suceess,error,"baiduMap","getRegion",[]);
};
//缩小地图，放大视角，放大一级比例尺，此接口自带动画效果
baiduMap.prototype.zoomIn = function(){
	exec(null,null,"baiduMap","zoomIn",[]);
};
//放大地图，缩小视角，缩小一级比例尺，此接口自带动画效果
baiduMap.prototype.zoomOut = function(){
	exec(null,null,"baiduMap","zoomOut",[]);
};		
//在地图上添加标注
baiduMap.prototype.addAnnotations = function(args,suceess,error){
	exec(suceess,error,"baiduMap","addAnnotations",[args]);
};	
 //在地图上移除标注
 baiduMap.prototype.removeAnnotations = function(args){
 	exec(null,null,"baiduMap","removeAnnotations",[args]);
 };
//在地图上移除所有的标注
baiduMap.prototype.removeAllAnno = function(){
	exec(null,null,"baiduMap","removeAllAnno",[]);
};		
 //获取指定标注的经纬度
 baiduMap.prototype.getAnnotationCoords = function(args,suceess,error){
 	exec(suceess,error,"baiduMap","getAnnotationCoords",[args]);
 };
 //设置某个已添加标注的经纬度
 baiduMap.prototype.updateAnnotationCoords = function(args){
 	exec(null,null,"baiduMap","updateAnnotationCoords",[args]);
 };
 //判断某个标注是否存在
 baiduMap.prototype.annotationExist = function(args,suceess,error){
 	exec(suceess,error,"baiduMap","annotationExist",[args]);
 };
//在地图上添加折线
baiduMap.prototype.addLine = function(args){
	exec(null,null,"baiduMap","addLine",[args]);
};
//在地图上添加多边形
baiduMap.prototype.addPolygon = function(args){
	exec(null,null,"baiduMap","addPolygon",[args]);
};
//在地图上添加弧形
baiduMap.prototype.addArc = function(args){
	exec(null,null,"baiduMap","addArc",[args]);
};
//在地图上添加圆
baiduMap.prototype.addCircle = function(args){
	exec(null,null,"baiduMap","addCircle",[args]);
};
//移除指定id的覆盖物(addLine/addPolygon/addArc/addCircle添加的覆盖物）
baiduMap.prototype.removeOverlay = function(args){
	exec(null,null,"baiduMap","removeOverlay",[args]);
};		
//离线地图初始化,使用离线地图之前必须调用此接口
baiduMap.prototype.offLineMapInit = function(){
	if (!this.offlineMap) {
		this.offlineMap = new offlineMap();
	};
	return this.offlineMap;
};
var offlineMap = function(){	
};
//添加离线地图事件的监听
offlineMap.prototype.addOfflineListener = function(callBack){
	exec(callBack,null,"baiduMap","addOfflineListener",[]);
};
//移除离线地图事件的监听
offlineMap.prototype.removeOfflineListener = function(){
	exec(null,null,"baiduMap","removeOfflineListener",[]);
};
//获取热门城市列表，无需调用 open 接口
offlineMap.prototype.getHotCityList = function(suceess,error){
	exec(suceess,error,"baiduMap","getHotCityList",[]);
};
//获取支持离线下载城市列表，无需调用 open 接口
offlineMap.prototype.getOfflineCityList = function(suceess,error){
    exec(suceess,error,"baiduMap","getOfflineCityList",[]);
};
//根据城市名搜索该城市离线地图记录，无需调用 open 接口
offlineMap.prototype.searchCityByName = function(args,suceess,error){
    exec(suceess,error,"baiduMap","searchCityByName",[args]);
};
//根据城市id获取更新信息
offlineMap.prototype.getUpdateInfo = function(args,suceess,error){
	exec(suceess,error,"baiduMap","getUpdateInfo",[args]);
};
//获取各城市离线地图更新信息，无需调用 open 接口
offlineMap.prototype.getAllUpdateInfo = function(suceess,error){
    exec(suceess,error,"baiduMap","getAllUpdateInfo",[]);
};
//启动下载指定城市 id 的离线地图,无需调用 open 接口
offlineMap.prototype.downLoad = function(args,callBack){
    exec(callBack,null,"baiduMap","downLoad",[args]);
};
//启动更新指定城市 id 的离线地图，无需调用 open 接口
offlineMap.prototype.update = function(args,suceess,error){
    exec(suceess,error,"baiduMap","update",[args]);
};
//暂停下载指定城市 id 的离线地图，无需调用 open 接口
offlineMap.prototype.pause = function(args){
    exec(null,null,"baiduMap","pause",[args]);
};
//删除下载指定城市 id 的离线地图，无需调用 open 接口
offlineMap.prototype.remove = function(args,callBack){
    exec(callBack,null,"baiduMap","remove",[args]);
};		
//获取地图上两点间的实际距离
baiduMap.prototype.getDistance = function(args,suceess,error){
	exec(suceess,error,"baiduMap","getDistance",[args]);
};
//将其它类型的地理坐标转换为百度坐标
baiduMap.prototype.transCoords = function(args,suceess,error){
	exec(suceess,error,"baiduMap","transCoords",[args]);
};

module.exports = new baiduMap();

});

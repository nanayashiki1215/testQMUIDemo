<!DOCTYPE HTML>
<html style="width:100%;height:100%" class="no-js">
    <head><meta http-equiv="Content-Type" content="text/html; charset=utf-8">
        <meta charset="utf-8">
        <meta http-equiv="X-UA-Compatible" content="IE=edge, chrome=1">
        <meta name="apple-mobile-web-app-capable" content="yes">
        <meta name="apple-mobile-web-app-status-bar-style" content="black">
        <meta name="format-detection" content="telephone=no">
        <meta name="renderer" content="webkit">
        <meta name="viewport" content="width=device-width,minimum-scale=1.0,maximum-scale=1.0,user-scalable=no,viewport-fit=cover">
        <script src="../system/lib/base/modernizr-2.8.3.min.js"></script>
		<script id="__varReplace">
    	
    	    	window.__justep = window.__justep || {};
				window.__justep.isDebug = false;
				window.__justep.__packageMode = "1";
				window.__justep.__isPackage = true;;
				window.__justep.url = location.href;
				window.__justep.versionInfo = {};
		 
    	</script>
        <script id="__updateVersion">
        
				(function(url, mode){
					if (("@"+"mode@") === mode) mode = "3";
					if (("@"+"versionUrl@") === url) url = "system/service/common/app.j";
					if ((mode!=="1" && (mode!="2") && (mode!="3"))) return;
					var async = (mode=="1");
					var x5Version = "noApp";
					var x5AppAgents = /x5app\/([0-9.]*)/.exec(navigator.userAgent);
					if(x5AppAgents && x5AppAgents.length > 1){
					   	x5Version = x5AppAgents[1] || "";
					} 
					function createXhr(){
						try {	
							return new XMLHttpRequest();
						}catch (tryMS) {	
							var version = ["MSXML2.XMLHttp.6.0",
							               "MSXML2.XMLHttp.3.0",
							               "MSXML2.XMLHttp",
							               "Miscrosoft.XMLHTTP"];
							for(var i = 0; i < version.length; i++){
								try{
							    	return new ActiveXObject(version[i]);
								}catch(e){}
							}
						}
						throw new Error("您的系统或浏览器不支持XHR对象！");
					}
					
					function createGuid(){	
						var guid = '';	
						for (var i = 1; i <= 32; i++){		
							var n = Math.floor(Math.random()*16.0).toString(16);		
							guid += n;		
							if((i==8)||(i==12)||(i==16)||(i==20))			
								guid += '-';	
						}	
						return guid;
					}
					
					function parseUrl(href){
						href = href.split("#")[0];
						var items = href.split("?");
						href = items[0];
						var query = items[1] || "";
						items = href.split("/");
						var baseItems = [];
						var pathItems = [];
						var isPath = false;
						for (var i=0; i<items.length; i++){
							if (mode == "3"){
								if (items[i] && (items[i].indexOf("v_") === 0) 
										&& (items[i].indexOf("l_") !== -1)
										&& (items[i].indexOf("s_") !== -1)
										&& (items[i].indexOf("d_") !== -1)
										|| (items[i]=="v_")){
									isPath = true;
									continue;
								}
							}else{
								if (items[i] && (items[i].indexOf("v-")===0) && (items[i].charAt(items[i].length-1)=="-") ){
									isPath = true;
									continue;
								}
							}
							if (isPath){
								pathItems.push(items[i]);
							}else{
								baseItems.push(items[i]);	
							}
							
						}
						var base = baseItems.join("/");
						if (base.charAt(base.length-1)!=="/") base += "/";
						
						var path = pathItems.join("/");
						if (path.charAt(0) !== "/") path = "/" + path;
						return [base, path, query];
					}
					
					
					var items = parseUrl(window.location.href);
					var base = items[0];
					var path = items[1];
					var query = items[2];
					var xhr = createXhr();
					url += ((url.indexOf("?")!=-1) ? "&" : "?") +"_=" + createGuid();
					if (mode === "3"){
						url += "&url=" + path;
						if (query)
							url += "&" + query;
					}
					xhr.open('GET', base + url, async);
					
					if (async){
						xhr.onreadystatechange=function(){
							if((xhr.readyState == 4) && (xhr.status == 200) && xhr.responseText){
								var versionInfo = JSON.parse(xhr.responseText);
								window.__justep.versionInfo = versionInfo;
								window.__justep.versionInfo.baseUrl = base;
								if (query){
									path = path + "?" + query;
								}
								path = versionInfo.resourceInfo.indexURL || path; /* 如果返回indexPath则使用indexPath，否则使用当前的path */
								var indexUrl = versionInfo.baseUrl + versionInfo.resourceInfo.version + path;
								versionInfo.resourceInfo.indexPageURL = indexUrl;
								if(versionInfo.resourceInfo.resourceUpdateMode != "md5"){
									if (window.__justep.url.indexOf(versionInfo.resourceInfo.version) == -1){
										versionInfo.resourceInfo.isNewVersion = true;
									};
								}
							}
						}
					}
					
					try{
						xhr.send(null);
						if (!async && (xhr.status == 200) && xhr.responseText){
							var versionInfo = JSON.parse(xhr.responseText);
							window.__justep.versionInfo = versionInfo;
							window.__justep.versionInfo.baseUrl = base;
							if ((mode==="3") && window.__justep.isDebug){
								/* 模式3且是调试模式不重定向 */
							}else{
								if (query){
									path = path + "?" + query;
								}
								if(versionInfo.resourceInfo.resourceUpdateMode == "md5"){
									path = versionInfo.resourceInfo.indexURL || path; /* 如果返回indexPath则使用indexPath，否则使用当前的path */
									var indexUrl = versionInfo.baseUrl + versionInfo.resourceInfo.version + path;
									versionInfo.resourceInfo.indexPageURL = indexUrl; 
								}else if (versionInfo.resourceInfo && versionInfo.resourceInfo.version && (window.__justep.url.indexOf(versionInfo.resourceInfo.version) == -1)){
									path = versionInfo.resourceInfo.indexURL || path; /* 如果返回indexPath则使用indexPath，否则使用当前的path */
									var indexUrl = versionInfo.baseUrl + versionInfo.resourceInfo.version + path;
									window.location.href = indexUrl;
								}
							}
						}
					}catch(e2){}
				}("appMetadata_in_server.json", "1"));
                 
        </script>
    <link rel="stylesheet" href="../system/components/bootstrap.min.css" include="$model/UI2/system/components/bootstrap/lib/css/bootstrap,$model/UI2/system/components/bootstrap/lib/css/bootstrap-theme"><link rel="stylesheet" href="../system/components/comp.min.css" include="$model/UI2/system/components/justep/lib/css2/dataControl,$model/UI2/system/components/justep/input/css/datePickerPC,$model/UI2/system/components/justep/messageDialog/css/messageDialog,$model/UI2/system/components/justep/lib/css3/round,$model/UI2/system/components/justep/input/css/datePicker,$model/UI2/system/components/justep/row/css/row,$model/UI2/system/components/justep/dataTables/css/responsive,$model/UI2/system/components/justep/attachment/css/attachment,$model/UI2/system/components/justep/barcode/css/barcodeImage,$model/UI2/system/components/bootstrap/dropdown/css/dropdown,$model/UI2/system/components/justep/contents/css/contents,$model/UI2/system/components/justep/common/css/forms,$model/UI2/system/components/justep/dataTables/css/responsive,$model/UI2/system/components/justep/locker/css/locker,$model/UI2/system/components/justep/menu/css/menu,$model/UI2/system/components/justep/scrollView/css/scrollView,$model/UI2/system/components/justep/loadingBar/loadingBar,$model/UI2/system/components/justep/dialog/css/dialog,$model/UI2/system/components/justep/bar/css/bar,$model/UI2/system/components/justep/popMenu/css/popMenu,$model/UI2/system/components/justep/lib/css/icons,$model/UI2/system/components/justep/lib/css4/e-commerce,$model/UI2/system/components/justep/toolBar/css/toolBar,$model/UI2/system/components/justep/popOver/css/popOver,$model/UI2/system/components/justep/panel/css/panel,$model/UI2/system/components/bootstrap/carousel/css/carousel,$model/UI2/system/components/justep/wing/css/wing,$model/UI2/system/components/bootstrap/scrollSpy/css/scrollSpy,$model/UI2/system/components/justep/titleBar/css/titleBar,$model/UI2/system/components/justep/lib/css1/linear,$model/UI2/system/components/justep/numberSelect/css/numberList,$model/UI2/system/components/justep/list/css/list,$model/UI2/system/components/justep/dataTables/css/dataTables"></head>
	
    <body style="width:100%;height:100%;margin: 0;">
        <script intro="none"></script>
    	<div id="applicationHost" class="applicationHost" style="width:100%;height:100%;" __component-context__="block"><div xid="window" class="window container-fluid c7RFJjm" component="$model/UI2/system/components/justep/window/window" design="device:m;" data-bind="component:{name:'$model/UI2/system/components/justep/window/window'}" __cid="c7RFJjm" components="$model/UI2/system/components/justep/model/model,$model/UI2/system/components/justep/loadingBar/loadingBar,$model/UI2/system/components/justep/button/button,$model/UI2/system/components/justep/input/input,$model/UI2/system/components/justep/scrollView/scrollView,$model/UI2/system/components/justep/list/list,$model/UI2/system/components/justep/panel/child,$model/UI2/system/components/justep/windowDialog/windowDialog,$model/UI2/system/components/justep/labelEdit/labelEdit,$model/UI2/system/components/justep/wing/child,$model/UI2/system/components/justep/panel/panel,$model/UI2/system/components/bootstrap/table/table,$model/UI2/system/components/justep/select/select,$model/UI2/system/components/justep/output/output,$model/UI2/system/components/justep/data/data,$model/UI2/system/components/justep/window/window,$model/UI2/system/components/justep/wing/wing,">
  <style>.x-dialog-title-text.c7RFJjm{color: white} .x-dialog.c7RFJjm .x-dialog-title.c7RFJjm{background-color: rgb(61, 179, 255)} .x-dialog-title.c7RFJjm .close.c7RFJjm{display: none}</style>  
  <div component="$model/UI2/system/components/justep/model/model" xid="model" style="display:none" data-bind="component:{name:'$model/UI2/system/components/justep/model/model'}" data-events="onLoad:modelLoad" __cid="c7RFJjm" class="c7RFJjm"></div>  
  <html lang="zh-CN" __cid="c7RFJjm" class="c7RFJjm"> 
    <head __cid="c7RFJjm" class="c7RFJjm"> 
      <meta charset="utf-8" __cid="c7RFJjm" class="c7RFJjm">  
      <meta http-equiv="X-UA-Compatible" content="IE=edge" __cid="c7RFJjm" class="c7RFJjm">  
      <meta name="viewport" content="width=device-width, initial-scale=1" __cid="c7RFJjm" class="c7RFJjm">  
      <title __cid="c7RFJjm" class="c7RFJjm">变电所运维云平台</title>  
      <link href="../app/css/bootstrap.min.css" rel="stylesheet" __cid="c7RFJjm" class="c7RFJjm">  
      <link href="../app/css/main.css" rel="stylesheet" __cid="c7RFJjm" class="c7RFJjm"> 
    </head> 
  </html>  
  <div xid="div5" __cid="c7RFJjm" class="c7RFJjm" data-bind="event:{click:$model._callModelFn.bind($model, 'div5Click')}"> 
    <span component="$model/UI2/system/components/justep/windowDialog/windowDialog" xid="windowDialog1" style="top:224px;left:783px;" data-bind="component:{name:'$model/UI2/system/components/justep/windowDialog/windowDialog'}" data-config="{&#34;forceRefreshOnOpen&#34;:false,&#34;height&#34;:&#34;auto&#34;,&#34;showTitle&#34;:true,&#34;src&#34;:&#34;$model/UI2/app/signalevent.w&#34;,&#34;status&#34;:&#34;normal&#34;,&#34;title&#34;:&#34;遥信事件详情&#34;,&#34;width&#34;:&#34;80%&#34;}" __cid="c7RFJjm" class="c7RFJjm">
      <div class="x-dialog-overlay c7RFJjm" __cid="c7RFJjm"></div>
      <div class="x-dialog c7RFJjm" style="display:none;" showTitle="true" __cid="c7RFJjm">
        <div class="x-dialog-title c7RFJjm" __cid="c7RFJjm">
          <button class="close c7RFJjm" __cid="c7RFJjm">
            <span __cid="c7RFJjm" class="c7RFJjm">×</span>
          </button>
          <div class="x-dialog-title-text c7RFJjm" __cid="c7RFJjm">遥信事件详情</div>
        </div>
        <div class="x-dialog-body c7RFJjm" __cid="c7RFJjm"></div>
      </div>
    </span>  
    <span component="$model/UI2/system/components/justep/windowDialog/windowDialog" xid="windowDialog2" style="top:180px;left:782px;" data-bind="component:{name:'$model/UI2/system/components/justep/windowDialog/windowDialog'}" data-config="{&#34;forceRefreshOnOpen&#34;:false,&#34;height&#34;:&#34;auto&#34;,&#34;showTitle&#34;:true,&#34;src&#34;:&#34;$model/UI2/app/overlimitevent.w&#34;,&#34;status&#34;:&#34;normal&#34;,&#34;title&#34;:&#34;越限事件详情&#34;}" __cid="c7RFJjm" class="c7RFJjm">
      <div class="x-dialog-overlay c7RFJjm" __cid="c7RFJjm"></div>
      <div class="x-dialog c7RFJjm" style="display:none;" showTitle="true" __cid="c7RFJjm">
        <div class="x-dialog-title c7RFJjm" __cid="c7RFJjm">
          <button class="close c7RFJjm" __cid="c7RFJjm">
            <span __cid="c7RFJjm" class="c7RFJjm">×</span>
          </button>
          <div class="x-dialog-title-text c7RFJjm" __cid="c7RFJjm">越限事件详情</div>
        </div>
        <div class="x-dialog-body c7RFJjm" __cid="c7RFJjm"></div>
      </div>
    </span> 
  </div>  
  <div component="$model/UI2/system/components/justep/wing/wing" class="x-wing c7RFJjm" xid="wing1" data-bind="component:{name:'$model/UI2/system/components/justep/wing/wing'}" __cid="c7RFJjm"> 
    <div class="x-wing-left c7RFJjm" xid="left1" style="background-color:#EDEEEE;border-right-style:solid;border-right-width:1px;border-color:#898989" component="$model/UI2/system/components/justep/wing/child" data-bind="component:{name:'$model/UI2/system/components/justep/wing/child'}" __cid="c7RFJjm"> 
      <div xid="div10" class="pull-left c7RFJjm" style="position:absolute;" __cid="c7RFJjm"> 
        <div xid="div4" __cid="c7RFJjm" class="c7RFJjm"> 
          <img src="../app/image/select.jpg" alt="" xid="image1" dir="rtl" style="width:100%;" __cid="c7RFJjm" class="c7RFJjm"> 
        </div>  
        <div component="$model/UI2/system/components/justep/labelEdit/labelEdit" class="x-label-edit x-label30 c7RFJjm" xid="labelEdit7" style="margin-top:5%;width:90%;margin-left:5%;" data-bind="component:{name:'$model/UI2/system/components/justep/labelEdit/labelEdit'}" __cid="c7RFJjm"> 
          <label class="x-label c7RFJjm" xid="label6" __cid="c7RFJjm">事件类型</label>  
          <select component="$model/UI2/system/components/justep/select/select" class="form-control x-edit c7RFJjm" xid="eventtype" data-bind="component:{name:'$model/UI2/system/components/justep/select/select'},options:eventtypedata.datas,optionsValue:'eventtype',optionsText:'typename',optionsAfterRender2:$model.__justep__.selectOptionsAfterRender.bind($model,$element),optionsBeforeRender:$model.__justep__.selectOptionsBeforeRender.bind($model,$element)" __cid="c7RFJjm"></select> 
        </div>  
        <div component="$model/UI2/system/components/justep/labelEdit/labelEdit" class="x-label-edit x-label30 c7RFJjm" xid="labelEdit3" style="width:90%;margin-left:5%;" data-bind="component:{name:'$model/UI2/system/components/justep/labelEdit/labelEdit'}" __cid="c7RFJjm"> 
          <label class="x-label c7RFJjm" xid="label2" __cid="c7RFJjm">变配电站</label>  
          <select component="$model/UI2/system/components/justep/select/select" class="form-control x-edit c7RFJjm" xid="subid" data-bind="component:{name:'$model/UI2/system/components/justep/select/select'},options:subdata.datas,optionsValue:'f_SubID',optionsText:'f_SubName',optionsAfterRender2:$model.__justep__.selectOptionsAfterRender.bind($model,$element),optionsBeforeRender:$model.__justep__.selectOptionsBeforeRender.bind($model,$element)" __cid="c7RFJjm"></select> 
        </div>  
        <div component="$model/UI2/system/components/justep/labelEdit/labelEdit" class="x-label-edit x-label30 pull-left c7RFJjm" xid="labelEdit6" style="left:10%;width:90%;margin-left:5%;" data-bind="component:{name:'$model/UI2/system/components/justep/labelEdit/labelEdit'}" __cid="c7RFJjm"> 
          <label class="x-label c7RFJjm" xid="label8" __cid="c7RFJjm">开始日期</label>  
          <input component="$model/UI2/system/components/justep/input/input" class="form-control x-edit c7RFJjm" xid="startdate" data-bind="component:{name:'$model/UI2/system/components/justep/input/input'}" data-config="{&#34;dataType&#34;:&#34;Date&#34;}" __cid="c7RFJjm"> 
        </div>  
        <div component="$model/UI2/system/components/justep/labelEdit/labelEdit" class="x-label-edit x-label30 c7RFJjm" xid="labelEdit8" style="width:90%;margin-left:5%;" data-bind="component:{name:'$model/UI2/system/components/justep/labelEdit/labelEdit'}" __cid="c7RFJjm"> 
          <label class="x-label c7RFJjm" xid="label7" __cid="c7RFJjm">结束日期</label>  
          <input component="$model/UI2/system/components/justep/input/input" class="form-control x-edit c7RFJjm" xid="enddate" data-bind="component:{name:'$model/UI2/system/components/justep/input/input'}" data-config="{&#34;dataType&#34;:&#34;Date&#34;}" __cid="c7RFJjm"> 
        </div>  
        <div xid="div11" style="width:90%;margin-left:5%;margin-top:5%;" __cid="c7RFJjm" class="c7RFJjm"> 
          <a component="$model/UI2/system/components/justep/button/button" class="btn btn-info c7RFJjm" xid="button2" style="height:100%;width:100%;border-width:thin thin thin thin;background-color:#FF6C1F;" data-bind="component:{name:'$model/UI2/system/components/justep/button/button'}" data-events="onClick:button2Click" data-config="{&#34;label&#34;:&#34;查询&#34;}" __cid="c7RFJjm"> 
            <i xid="i6" __cid="c7RFJjm" class="c7RFJjm"></i>  
            <span xid="span4" __cid="c7RFJjm" class="c7RFJjm">查询</span> 
          </a> 
        </div> 
      </div> 
    </div>  
    <div class="x-wing-content c7RFJjm" xid="content2" component="$model/UI2/system/components/justep/wing/child" data-bind="component:{name:'$model/UI2/system/components/justep/wing/child'}" __cid="c7RFJjm"> 
      <div component="$model/UI2/system/components/justep/panel/panel" class="x-panel x-full pcumMNbu-iosstatusbar c7RFJjm" xid="panel1" data-bind="component:{name:'$model/UI2/system/components/justep/panel/panel'}" __cid="c7RFJjm"> 
        <div class="x-panel-top c7RFJjm" xid="top1" component="$model/UI2/system/components/justep/panel/child" data-bind="component:{name:'$model/UI2/system/components/justep/panel/child'}" __cid="c7RFJjm"> 
          <nav class="nav center c7RFJjm" xid="default3" __cid="c7RFJjm"> 
            <i class="left c7RFJjm" xid="i4" __cid="c7RFJjm" data-bind="event:{click:$model._callModelFn.bind($model, {operation:'window.close'})}"></i>  
            <span xid="span3" __cid="c7RFJjm" class="c7RFJjm">事件</span>  
            <a href="#" xid="a1" __cid="c7RFJjm" class="c7RFJjm"></a>  
            <div class="menu-list c7RFJjm" xid="div9" __cid="c7RFJjm"> 
              <ul xid="ul1" __cid="c7RFJjm" class="c7RFJjm"> 
                <li xid="li1" __cid="c7RFJjm" class="c7RFJjm"> 
                  <a href="#" xid="a2" __cid="c7RFJjm" class="c7RFJjm">地图导航</a> 
                </li>  
                <li xid="li2" __cid="c7RFJjm" class="c7RFJjm"> 
                  <a href="#" xid="a3" __cid="c7RFJjm" class="c7RFJjm">变配电站概况</a> 
                </li>  
                <li class="inspect c7RFJjm" xid="li3" __cid="c7RFJjm"> 
                  <h2 xid="h21" __cid="c7RFJjm" class="c7RFJjm"> 
                    <a href="#" xid="a4" __cid="c7RFJjm" class="c7RFJjm">巡检管理</a>  
                    <i class="foldIcon c7RFJjm" xid="i5" __cid="c7RFJjm"></i> 
                  </h2>  
                  <ul class="menu-child c7RFJjm" xid="ul2" __cid="c7RFJjm"> 
                    <li xid="li4" __cid="c7RFJjm" class="c7RFJjm"> 
                      <a href="#" xid="a5" __cid="c7RFJjm" class="c7RFJjm">巡检任务</a> 
                    </li>  
                    <li xid="li5" __cid="c7RFJjm" class="c7RFJjm"> 
                      <a href="#" xid="a6" __cid="c7RFJjm" class="c7RFJjm">任务执行</a> 
                    </li>  
                    <li xid="li6" __cid="c7RFJjm" class="c7RFJjm"> 
                      <a href="#" xid="a7" __cid="c7RFJjm" class="c7RFJjm">查询任务</a> 
                    </li> 
                  </ul> 
                </li>  
                <li xid="li7" __cid="c7RFJjm" class="c7RFJjm"> 
                  <a href="#" xid="a8" __cid="c7RFJjm" class="c7RFJjm">事件</a> 
                </li> 
              </ul> 
            </div> 
          </nav> 
        </div>  
        <div class="x-panel-content  x-scroll-view c7RFJjm" xid="content1" _xid="C799CEF4D7E00001D8FC14A019972300" style="bottom: 0px; top: 43px;" component="$model/UI2/system/components/justep/panel/child" data-bind="component:{name:'$model/UI2/system/components/justep/panel/child'},event:{click:$model._callModelFn.bind($model, 'content1Click')}" __cid="c7RFJjm"> 
          <div class="x-scroll c7RFJjm" component="$model/UI2/system/components/justep/scrollView/scrollView" xid="scrollView1" data-bind="component:{name:'$model/UI2/system/components/justep/scrollView/scrollView'}" data-events="onPullDown:scrollView1PullDown" data-config="{&#34;autoAppend&#34;:true}" __cid="c7RFJjm"> 
            <div class="x-content-center x-pull-down container c7RFJjm" xid="div2" __cid="c7RFJjm"> 
              <i class="x-pull-down-img glyphicon x-icon-pull-down c7RFJjm" xid="i1" __cid="c7RFJjm"></i>  
              <span class="x-pull-down-label c7RFJjm" xid="span1" __cid="c7RFJjm">下拉刷新...</span> 
            </div>  
            <div class="x-scroll-content c7RFJjm" xid="div3" __cid="c7RFJjm"> 
              <div xid="div1" __cid="c7RFJjm" class="c7RFJjm"> 
                <a component="$model/UI2/system/components/justep/button/button" class="btn btn-info c7RFJjm" xid="button1" style="margin:7px 0px 0px 0px;" data-bind="component:{name:'$model/UI2/system/components/justep/button/button'}" data-events="onClick:button1Click" data-config="{&#34;label&#34;:&#34;筛选&#34;}" __cid="c7RFJjm"> 
                  <i xid="i2" __cid="c7RFJjm" class="c7RFJjm"></i>  
                  <span xid="span2" __cid="c7RFJjm" class="c7RFJjm">筛选</span> 
                </a>  
                <div component="$model/UI2/system/components/justep/output/output" class="x-output pull-right x-edit c7RFJjm" xid="subname" style="font-size:16px;font-weight:600;margin-top:5px;margin-right:10px;" data-bind="component:{name:'$model/UI2/system/components/justep/output/output'}" __cid="c7RFJjm"></div> 
              </div>  
              <div component="$model/UI2/system/components/justep/list/list" class="x-list c7RFJjm" xid="list4" data-bind="component:{name:'$model/UI2/system/components/justep/list/list'}" data-config="{&#34;data&#34;:&#34;eventdata&#34;,&#34;disableInfiniteLoad&#34;:false,&#34;disablePullToRefresh&#34;:true,&#34;limit&#34;:11}" __cid="c7RFJjm"> 
                <table class="table table-bordered table-hover table-striped c7RFJjm" component="$model/UI2/system/components/bootstrap/table/table" xid="table2" data-bind="component:{name:'$model/UI2/system/components/bootstrap/table/table'}" __cid="c7RFJjm"> 
                  <thead xid="thead4" __cid="c7RFJjm" class="c7RFJjm"> 
                    <tr xid="tr6" __cid="c7RFJjm" class="c7RFJjm"> 
                      <th xid="col11" style="text-align:center;background-color:#3DB3FF;width:110px;color:#FFFFFF;" __cid="c7RFJjm" class="c7RFJjm">时间</th>  
                      <th xid="col1" style="text-align:center;background-color:#3DB3FF;color:#FFFFFF;" __cid="c7RFJjm" class="c7RFJjm">仪表</th>  
                      <th xid="col14" style="text-align:center;background-color:#3DB3FF;color:#FFFFFF;" __cid="c7RFJjm" class="c7RFJjm">类型</th>  
                      <th xid="col2" style="text-align:center;background-color:#3DB3FF;color:#FFFFFF;" __cid="c7RFJjm" class="c7RFJjm">详情</th> 
                    </tr> 
                  </thead>  
                  <tbody class="x-list-template hide c7RFJjm" xid="listTemplate3" __cid="c7RFJjm" data-bind="foreach:{data:$model.foreach_list4($element),afterRender:$model.foreach_afterRender_list4.bind($model,$element)}"> 
                    <tr xid="tr7" __cid="c7RFJjm" class="c7RFJjm"> 
                      <td xid="td7" __cid="c7RFJjm" class="c7RFJjm" data-bind="text:ref(&#34;starttime&#34;)"></td>  
                      <td xid="td1" __cid="c7RFJjm" class="c7RFJjm" data-bind="text:ref(&#34;metername&#34;)"></td>  
                      <td xid="td10" __cid="c7RFJjm" class="c7RFJjm" data-bind="text:ref(&#34;alarmtype&#34;)"></td>  
                      <td xid="td9" style="text-align:center;" __cid="c7RFJjm" class="c7RFJjm"> 
                        <a component="$model/UI2/system/components/justep/button/button" class="btn btn-info c7RFJjm" xid="button3" style="background-color:#FF6C1F;" data-bind="component:{name:'$model/UI2/system/components/justep/button/button'}" data-events="onClick:button3Click" data-config="{&#34;label&#34;:&#34;详情&#34;}" __cid="c7RFJjm"> 
                          <i xid="i3" __cid="c7RFJjm" class="c7RFJjm"></i>  
                          <span xid="span8" __cid="c7RFJjm" class="c7RFJjm">详情</span> 
                        </a> 
                      </td> 
                    </tr> 
                  </tbody> 
                </table> 
              </div> 
            </div>  
            <div class="x-content-center x-pull-up c7RFJjm" xid="div6" __cid="c7RFJjm"></div> 
          </div> 
        </div>  
        <style __cid="c7RFJjm" class="c7RFJjm">.x-panel.pcumMNbu-iosstatusbar >.x-panel-top {height: 43px;}.x-panel.pcumMNbu-iosstatusbar >.x-panel-content { top: 43px;bottom: nullpx;}.x-panel.pcumMNbu-iosstatusbar >.x-panel-bottom {height: nullpx;}.iosstatusbar .x-panel.pcumMNbu-iosstatusbar >.x-panel-top,.iosstatusbar .x-panel .x-panel-content .x-has-iosstatusbar.x-panel.pcumMNbu-iosstatusbar >.x-panel-top {height: 63px;}.iosstatusbar .x-panel.pcumMNbu-iosstatusbar >.x-panel-content,.iosstatusbar .x-panel .x-panel-content .x-has-iosstatusbar.x-panel.pcumMNbu-iosstatusbar >.x-panel-content { top: 63px;}.iosstatusbar .x-panel .x-panel-content .x-panel.pcumMNbu-iosstatusbar >.x-panel-top {height: 43px;}.iosstatusbar .x-panel .x-panel-content .x-panel.pcumMNbu-iosstatusbar >.x-panel-content {top: 43px;}</style>
      </div> 
    </div> 
  </div> 
</div></div>
        
        <div id="downloadGCF" style="display:none;padding:50px;">
        	<span>您使用的浏览器需要下载插件才能使用, </span>
        	<a id="downloadGCFLink" href="#">下载地址</a>
        	<p>(安装后请重新打开浏览器)</p>
        </div>
    	<script>
    	
    	            //判断浏览器, 判断GCF
    	 			var browser = {
    			        isIe: function () {
    			            return navigator.appVersion.indexOf("MSIE") != -1;
    			        },
    			        navigator: navigator.appVersion,
    			        getVersion: function() {
    			            var version = 999; // we assume a sane browser
    			            if (navigator.appVersion.indexOf("MSIE") != -1)
    			                // bah, IE again, lets downgrade version number
    			                version = parseFloat(navigator.appVersion.split("MSIE")[1]);
    			            return version;
    			        }
    			    };
    				function isGCFInstalled(){
    			      try{
    			        var i = new ActiveXObject('ChromeTab.ChromeFrame');
    			        if (i) {
    			          return true;
    			        }
    			      }catch(e){}
    			      return false;
    				}
    	            //判断浏览器, 判断GCF
    	            var __continueRun = true;
    				if (browser.isIe() && (browser.getVersion() < 10) && !isGCFInstalled()) {
    					document.getElementById("applicationHost").style.display = 'none';
    					document.getElementById("downloadGCF").style.display = 'block';
    					var downloadLink = "/" + location.pathname.match(/[^\/]+/)[0] + "/v8.msi";
    					document.getElementById("downloadGCFLink").href = downloadLink; 
    					__continueRun = false;
    	            }
		 	
    	</script>
        
        <script id="_requireJS" src="../system/lib/require/require.2.1.10.js"> </script>
        <script src="../system/core.min.js"></script><script src="../system/common.min.js"></script><script src="../system/components/comp.min.js"></script><script src="../system/components/comp2.min.js"></script><script id="_mainScript">
        
			if (__continueRun) {
                window.__justep.cssReady = function(fn){
                	var promises = [];
                	for (var p in window.__justep.__ResourceEngine.__loadingCss){
                		if(window.__justep.__ResourceEngine.__loadingCss.hasOwnProperty(p))
                			promises.push(window.__justep.__ResourceEngine.__loadingCss[p].promise());
                	}
                	$.when.apply($, promises).done(fn);
                };
                
            	window.__justep.__ResourceEngine = {
            		readyRegExp : navigator.platform === 'PLAYSTATION 3' ? /^complete$/ : /^(complete|loaded)$/,
            		url: window.location.href,	
            		/*contextPath: 不包括语言 */
            		contextPath: "",
            		serverPath: "",
            		__loadedJS: [],
            		__loadingCss: {},
            		onLoadCss: function(url, node){
            			if (!this.__loadingCss[url]){
            				this.__loadingCss[url] = $.Deferred();	
                			if (node.attachEvent &&
                                    !(node.attachEvent.toString && node.attachEvent.toString().indexOf('[native code') < 0) &&
                                    !(typeof opera !== 'undefined' && opera.toString() === '[object Opera]')) {
                                node.attachEvent('onreadystatechange', this.onLinkLoad.bind(this));
                            } else {
                                node.addEventListener('load', this.onLinkLoad.bind(this), false);
                                node.addEventListener('error', this.onLinkError.bind(this), false);
                            }
            			}
            		},
            		
            		onLinkLoad: function(evt){
            	        var target = (evt.currentTarget || evt.srcElement);
            	        if (evt.type === 'load' ||
                                (this.readyRegExp.test(target.readyState))) {
            	        	var url = target.getAttribute("href");
            	        	if (url && window.__justep.__ResourceEngine.__loadingCss[url]){
            	        		window.__justep.__ResourceEngine.__loadingCss[url].resolve(url);
            	        	}
                        }
            		},
            		
            		onLinkError: function(evt){
            	        var target = (evt.currentTarget || evt.srcElement);
        	        	var url = target.getAttribute("href");
        	        	if (url && window.__justep.__ResourceEngine.__loadingCss[url]){
        	        		window.__justep.__ResourceEngine.__loadingCss[url].resolve(url);
        	        	}
            		},
            		
            		initContextPath: function(){
            			var baseURL = document.getElementById("_requireJS").src;
            			var before = location.protocol + "//" + location.host;
            			var after = "/system/lib/require/require.2.1.10";
            			var i = baseURL.indexOf(after);
            			if (i !== -1){
    	        			var middle = baseURL.substring(before.length, i);
    						var items = middle.split("/");
    						
    						
    						if ((items[items.length-1].indexOf("v_") === 0) 
    								&& (items[items.length-1].indexOf("l_") !== -1)
    								&& (items[items.length-1].indexOf("s_") !== -1)
    								&& (items[items.length-1].indexOf("d_") !== -1)
    								|| (items[items.length-1]=="v_")){
    							items.splice(items.length-1, 1);
    						}
    						
    						
    						if (items.length !== 1){
    							window.__justep.__ResourceEngine.contextPath = items.join("/");
    						}else{
    							window.__justep.__ResourceEngine.contextPath = before;
    						}
    						var index = window.__justep.__ResourceEngine.contextPath.lastIndexOf("/");
    						if (index != -1){
    							window.__justep.__ResourceEngine.serverPath = window.__justep.__ResourceEngine.contextPath.substr(0, index);
    						}else{
    							window.__justep.__ResourceEngine.serverPath = window.__justep.__ResourceEngine.contextPath;
    						}
            			}else{
            				throw new Error(baseURL + " hasn't  " + after);
            			}
            		},
            	
            		loadJs: function(urls){
            			if (urls && urls.length>0){
            				var loadeds = this._getResources("script", "src").concat(this.__loadedJS);
    	       				for (var i=0; i<urls.length; i++){
								var url = urls[i];
    	        				if(!this._isLoaded(url, loadeds)){
    	        					this.__loadedJS[this.__loadedJS.length] = url;
    	        					/*
    	        					var script = document.createElement("script");
    	        					script.src = url;
    	        					document.head.appendChild(script);
    	        					*/
    	        					//$("head").append("<script  src='" + url + "'/>");
									var url = require.toUrl("$UI" + url);
    	        					$.ajax({
    	        						url: url,
    	        						dataType: "script",
    	        						cache: true,
    	        						async: false,
    	        						success: function(){}
    	        						});
    	        				} 
    	       				}
            			}
            		},
            		
            		loadCss: function(styles){
           				var loadeds = this._getResources("link", "href");
            			if (styles && styles.length>0){
            				for (var i=0; i<styles.length; i++){
    	       					var url = window.__justep.__ResourceEngine.contextPath + styles[i].url.replace("/UI2/", "/");
    	        				if(!this._isLoaded(url, loadeds)){
    	        					var include = styles[i].include || "";
    	        					var link = $("<link type='text/css' rel='stylesheet' href='" + url + "' include='" + include + "'/>");
    	        					this.onLoadCss(url, link[0]);
    	        					$("head").append(link);
    	        				} 
            				}
            			}
            			
            		},
            		
            		
            		_isLoaded: function(url, loadeds){
            			if (url){
            				var newUrl = "";
            				var items = url.split("/");
            				var isVls = false;
            				for (var i=0; i<items.length; i++){
            					if (isVls){
                					newUrl += "/" + items[i];
            					}else{
                					if (items[i] && (items[i].indexOf("v_")===0)
            								&& (items[i].indexOf("l_")!==-1)
            								&& (items[i].indexOf("s_")!==-1)
            								&& (items[i].indexOf("d_")!==-1)
            								|| (items[i]=="v_")){
                						isVls = true;
                					}
            					}
            				}
            				if (!newUrl)
            					newUrl = url;
            				
            				for (var i=0; i<loadeds.length; i++){
								var originUrl = this._getOriginUrl(loadeds[i]);
								if (originUrl && (originUrl.indexOf(newUrl)!==-1)){
									return true;
								}
    						}
            			}
    					return false;
            		},

					_getOriginUrl: function(url){
						var result = "";
						if (url && (url.indexOf(".md5_")!==-1)){
							url = url.split("#")[0];
							url = url.split("?")[0];
							var items = url.split(".");
							for (var i=0; i<items.length; i++){
								if ((i===items.length-2) && (items[i].indexOf("md5_")!==-1)){
									continue;
								}else{
									if (i>0) result += ".";
									result += items[i];
								}
							}
						}else{
							result = url;
						}
						return result;
					},
            		
            		_getResources: function(tag, attr){
    					var result = [];
    					var scripts = $(tag);
    					for (var i=0; i<scripts.length; i++){
    						var v = scripts[i][attr];
    						if (v){
    							result[result.length] = v;
    						}
    					}
    					return result;
            		}
            	};
            	
            	window.__justep.__ResourceEngine.initContextPath();
    			requirejs.config({
    				baseUrl: window.__justep.__ResourceEngine.contextPath + '/app',
    			    paths: {
    			    	/* 解决require.normalizeName与require.toUrl嵌套后不一致的bug   */
    			    	'$model/UI2/v_': window.__justep.__ResourceEngine.contextPath + '',
    			    	'$model/UI2': window.__justep.__ResourceEngine.contextPath + '',
    			    	'$model': window.__justep.__ResourceEngine.serverPath,
    			        'text': window.__justep.__ResourceEngine.contextPath + '/system/lib/require/text.2.0.10',
    			        'bind': window.__justep.__ResourceEngine.contextPath + '/system/lib/bind/bind',
    			        'jquery': window.__justep.__ResourceEngine.contextPath + '/system/lib/jquery/jquery-1.11.1.min'
    			    },
    			    map: {
    				        '*': {
    				            res: '$model/UI2/system/lib/require/res',
    				            service: '$model/UI2/system/lib/require/service',
    				            cordova: '$model/UI2/system/lib/require/cordova',
    				            w: '$model/UI2/system/lib/require/w',
    				            css: '$model/UI2/system/lib/require/css'
    				        }
    				},
    				waitSeconds: 300
    			});
    			
    			requirejs(['require', 'jquery', '$model/UI2/system/lib/base/composition', '$model/UI2/system/lib/base/url', '$model/UI2/system/lib/route/hashbangParser', '$model/UI2/system/components/justep/versionChecker/versionChecker', '$model/UI2/system/components/justep/loadingBar/loadingBar', '$model/UI2/system/lib/jquery/domEvent',  '$model/UI2/system/lib/cordova/cordova'],  function (require, $, composition, URL, HashbangParser,versionChecker) { 
    				document.addEventListener('deviceready', function() {
    	                if (navigator && navigator.splashscreen && navigator.splashscreen.hide) {
    	                	/*延迟隐藏，视觉效果更理想*/
    	                	setTimeout(function() {navigator.splashscreen.hide();}, 800);
    	                }
    	            }, false);
					setTimeout(function(){
						versionChecker.check();
					},2000);
    				var context = {};
    				context.model = '$model/UI2/app/event.w' + (document.location.search || "");
    				context.view = $('#applicationHost').children()[0];
    				var element = document.getElementById('applicationHost');

					    				
    				
    				var ownerid = new URL(window.__justep.__ResourceEngine.url).getParam("$ownerid");
    				var pwindow = opener;
    				if (!pwindow && window.parent && window.parent.window){
    					pwindow = window.parent.window;
    				}
    				if(ownerid && pwindow 
    						&& pwindow.__justep && pwindow.__justep.windowOpeners
    						&& pwindow.__justep.windowOpeners[ownerid]
    						&& $.isFunction(pwindow.__justep.windowOpeners[ownerid].sendToWindow)){
    					window.__justep.setParams = function(params){
    						/* 给windowOpener提供再次传参数的接口  */
    						params = params || {};
    						composition.setParams(document.getElementById('applicationHost'), params);
    					};
    					var winOpener = pwindow.__justep.windowOpeners[ownerid];
    					if(winOpener) winOpener.window = window;
    					$(window).unload(function(event){
    						if(winOpener && winOpener.dispatchCloseEvent) winOpener.dispatchCloseEvent();
    					});
    					var params = winOpener.sendToWindow();
						context.owner = winOpener;
						context.params = params || {};
	        			composition.compose(element, context);
    				}else{
        				var params =  {};
    					var state = new HashbangParser(window.location.hash).parse().__state;
    					if (state){
    						params = state.get("");
    						try{
    							params = JSON.parse(params);
    							if (params.hasOwnProperty("__singleValue__")){
    								params = params.__singleValue__;
    							}
    						}catch(e1){}
    					}
    					context.noUpdateState = true;
        				context.params = params;
        				composition.compose(element, context);
    				}
    			});    
            }
		 	
        </script>
    </body>
</html>
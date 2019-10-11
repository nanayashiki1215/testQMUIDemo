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
    	<div id="applicationHost" class="applicationHost" style="width:100%;height:100%;" __component-context__="block"><div xid="window" class="window container-fluid cyMRBBz" component="$model/UI2/system/components/justep/window/window" design="device:m;" data-bind="component:{name:'$model/UI2/system/components/justep/window/window'}" __cid="cyMRBBz" components="$model/UI2/system/components/justep/model/model,$model/UI2/system/components/justep/loadingBar/loadingBar,$model/UI2/system/components/justep/panel/child,$model/UI2/system/components/justep/windowDialog/windowDialog,$model/UI2/system/components/justep/window/window,$model/UI2/system/components/justep/messageDialog/messageDialog,$model/UI2/system/components/justep/panel/panel,">
  <style>null</style>  
  <html lang="zh-CN" __cid="cyMRBBz" class="cyMRBBz"> 
    <meta charset="utf-8" __cid="cyMRBBz" class="cyMRBBz">  
    <meta http-equiv="X-UA-Compatible" content="IE=edge" __cid="cyMRBBz" class="cyMRBBz">  
    <meta name="viewport" content="width=device-width, initial-scale=1" __cid="cyMRBBz" class="cyMRBBz">  
    <title __cid="cyMRBBz" class="cyMRBBz">企业用电运维云平台云平台</title>  
    <link href="../app/css/bootstrap.min.css" rel="stylesheet" __cid="cyMRBBz" class="cyMRBBz">  
    <link href="../app/css/main.css" rel="stylesheet" __cid="cyMRBBz" class="cyMRBBz"> 
  </html>
  <div component="$model/UI2/system/components/justep/model/model" xid="model" style="display:none" data-bind="component:{name:'$model/UI2/system/components/justep/model/model'}" data-events="onActive:modelActive;onInactive:modelInactive;onLoad:modelLoad" __cid="cyMRBBz" class="cyMRBBz"></div>  
  <span component="$model/UI2/system/components/justep/messageDialog/messageDialog" xid="logout" style="top:310px;left:139px;" data-bind="component:{name:'$model/UI2/system/components/justep/messageDialog/messageDialog'}" data-events="onCancel:logoutOK" data-config="{&#34;message&#34;:&#34;确定要退出登录吗？&#34;,&#34;type&#34;:&#34;OKCancel&#34;}" __cid="cyMRBBz" class="cyMRBBz">
    <div class="x-modal-overlay cyMRBBz" __cid="cyMRBBz"></div>
    <div class="x-modal cyMRBBz" __cid="cyMRBBz">
      <div class="x-modal-inner cyMRBBz" __cid="cyMRBBz">
        <div class="x-modal-title cyMRBBz" __cid="cyMRBBz"></div>
        <div class="x-modal-text cyMRBBz" __cid="cyMRBBz">确定要退出登录吗？</div>
        <input class="x-modal-prompt-input cyMRBBz" type="text" __cid="cyMRBBz">
      </div>
      <div class="x-modal-buttons cyMRBBz" __cid="cyMRBBz">
        <a class="x-modal-button x-modal-button-bold OK cyMRBBz" value="ok" __cid="cyMRBBz">确定</a>
        <a class="x-modal-button x-modal-button-bold Yes cyMRBBz" value="yes" __cid="cyMRBBz">是</a>
        <a class="x-modal-button x-modal-button-bold No cyMRBBz" value="no" __cid="cyMRBBz">否</a>
        <a class="x-modal-button x-modal-button-bold Cancel cyMRBBz" value="cancel" __cid="cyMRBBz">取消</a>
      </div>
    </div>
  </span>  
  <span component="$model/UI2/system/components/justep/windowDialog/windowDialog" xid="loginDialog" style="top:345px;left:364px;" data-bind="component:{name:'$model/UI2/system/components/justep/windowDialog/windowDialog'}" data-config="{&#34;forceRefreshOnOpen&#34;:true,&#34;src&#34;:&#34;$model/UI2/app/login.w&#34;}" __cid="cyMRBBz" class="cyMRBBz">
    <div class="x-dialog-overlay cyMRBBz" __cid="cyMRBBz"></div>
    <div class="x-dialog cyMRBBz" style="display:none;" __cid="cyMRBBz">
      <div class="x-dialog-title cyMRBBz" __cid="cyMRBBz">
        <button class="close cyMRBBz" __cid="cyMRBBz">
          <span __cid="cyMRBBz" class="cyMRBBz">×</span>
        </button>
        <div class="x-dialog-title-text cyMRBBz" __cid="cyMRBBz"></div>
      </div>
      <div class="x-dialog-body cyMRBBz" __cid="cyMRBBz"></div>
    </div>
  </span>  
  <div xid="div1" __cid="cyMRBBz" class="cyMRBBz" data-bind="event:{click:$model._callModelFn.bind($model, 'div1Click')}">
    <span component="$model/UI2/system/components/justep/windowDialog/windowDialog" xid="windowDialog1" style="top:339px;left:433px;" data-bind="component:{name:'$model/UI2/system/components/justep/windowDialog/windowDialog'}" data-config="{&#34;height&#34;:&#34;auto&#34;,&#34;routable&#34;:true,&#34;showTitle&#34;:false,&#34;src&#34;:&#34;$model/UI2/app/inspect.w&#34;,&#34;status&#34;:&#34;normal&#34;,&#34;width&#34;:&#34;auto&#34;}" __cid="cyMRBBz" class="cyMRBBz">
      <div class="x-dialog-overlay cyMRBBz" __cid="cyMRBBz"></div>
      <div class="x-dialog cyMRBBz" style="display:none;" showTitle="false" __cid="cyMRBBz">
        <div class="x-dialog-title cyMRBBz" __cid="cyMRBBz">
          <button class="close cyMRBBz" __cid="cyMRBBz">
            <span __cid="cyMRBBz" class="cyMRBBz">×</span>
          </button>
          <div class="x-dialog-title-text cyMRBBz" __cid="cyMRBBz"></div>
        </div>
        <div class="x-dialog-body cyMRBBz" __cid="cyMRBBz"></div>
      </div>
    </span>
  </div>  
  <div component="$model/UI2/system/components/justep/panel/panel" class="x-panel x-full x-has-iosstatusbar pcviayya-iosstatusbar cyMRBBz" xid="panel2" data-bind="component:{name:'$model/UI2/system/components/justep/panel/panel'}" __cid="cyMRBBz"> 
    <div class="x-panel-top cyMRBBz" xid="top1" component="$model/UI2/system/components/justep/panel/child" data-bind="component:{name:'$model/UI2/system/components/justep/panel/child'}" __cid="cyMRBBz">
      <nav class="nav cyMRBBz" style="text-align:center" __cid="cyMRBBz"> 
        <span __cid="cyMRBBz" class="cyMRBBz">电力运维云平台</span>  
        <a href="#" __cid="cyMRBBz" class="cyMRBBz"> 
          <img src="../app/image/menu.png" class="menu cyMRBBz" xid="menu" __cid="cyMRBBz"> 
        </a>  
        <div class="menu-list cyMRBBz" __cid="cyMRBBz"> 
          <ul __cid="cyMRBBz" class="cyMRBBz"> 
            <li id="logout" __cid="cyMRBBz" class="cyMRBBz"> 
              <a href="#" __cid="cyMRBBz" class="cyMRBBz" data-bind="event:{click:$model._callModelFn.bind($model, 'logoutClick')}">退出登录</a> 
            </li> 
          </ul> 
        </div> 
      </nav> 
    </div>  
    <div class="x-panel-content  cyMRBBz" xid="content1" component="$model/UI2/system/components/justep/panel/child" data-bind="component:{name:'$model/UI2/system/components/justep/panel/child'}" __cid="cyMRBBz">
      <div __cid="cyMRBBz" class="cyMRBBz"> 
        <img src="../app/image/banner.png" class="banner cyMRBBz" __cid="cyMRBBz">  
        <ul class="main-menu cyMRBBz" __cid="cyMRBBz"> 
          <li __cid="cyMRBBz" class="cyMRBBz"> 
            <span class="map cyMRBBz" xid="map" __cid="cyMRBBz" data-bind="event:{click:$model._callModelFn.bind($model, 'mapClick')}"></span>  
            <p __cid="cyMRBBz" class="cyMRBBz">地图导航</p> 
          </li>  
          <li __cid="cyMRBBz" class="cyMRBBz"> 
            <span class="survey cyMRBBz" __cid="cyMRBBz" data-bind="event:{click:$model._callModelFn.bind($model, 'span2Click')}"></span>  
            <p __cid="cyMRBBz" class="cyMRBBz">变配电站概况</p> 
          </li>  
          <li xid="myModal2" __cid="cyMRBBz" class="cyMRBBz" data-bind="event:{click:$model._callModelFn.bind($model, 'myModal2Click')}"> 
            <span class="manage cyMRBBz" __cid="cyMRBBz"></span>  
            <p __cid="cyMRBBz" class="cyMRBBz">巡检管理</p> 
          </li>  
          <li __cid="cyMRBBz" class="cyMRBBz"> 
            <span class="event cyMRBBz" __cid="cyMRBBz" data-bind="event:{click:$model._callModelFn.bind($model, 'span3Click')}"></span>  
            <p __cid="cyMRBBz" class="cyMRBBz">事件</p> 
          </li>  
          <li __cid="cyMRBBz" class="cyMRBBz"> 
            <span class="elec cyMRBBz" __cid="cyMRBBz" data-bind="event:{click:$model._callModelFn.bind($model, 'span1Click')}"></span>  
            <p __cid="cyMRBBz" class="cyMRBBz">电力参数</p> 
          </li>  
          <li __cid="cyMRBBz" class="cyMRBBz"> 
            <span xid="span1" class="safe cyMRBBz" __cid="cyMRBBz" data-bind="event:{click:$model._callModelFn.bind($model, 'safespanClick')}"></span>
            <p __cid="cyMRBBz" class="cyMRBBz">线缆温度</p> 
          </li>  
          <li xid="li2" __cid="cyMRBBz" class="cyMRBBz">
            <span xid="video" class="videoli cyMRBBz" __cid="cyMRBBz" data-bind="event:{click:$model._callModelFn.bind($model, 'videoClick')}"></span>  
            <p xid="p2" __cid="cyMRBBz" class="cyMRBBz">视频直播</p>
          </li>
        </ul> 
      </div>
    </div>  
    <div class="x-panel-bottom cyMRBBz" xid="bottom1" component="$model/UI2/system/components/justep/panel/child" data-bind="component:{name:'$model/UI2/system/components/justep/panel/child'}" data-config="{&#34;height&#34;:67}" __cid="cyMRBBz">
      <nav class="nav-bottom cyMRBBz" __cid="cyMRBBz"> 
        <ul __cid="cyMRBBz" class="cyMRBBz"> 
          <li __cid="cyMRBBz" class="cyMRBBz"> 
            <span class="index cyMRBBz" __cid="cyMRBBz"></span>  
            <p __cid="cyMRBBz" class="cyMRBBz">主页</p> 
          </li>  
          <li __cid="cyMRBBz" class="cyMRBBz" data-bind="event:{click:$model._callModelFn.bind($model, 'li1Click')}"> 
            <span class="alarm cyMRBBz" __cid="cyMRBBz"> 
              <p id="eventnum" xid="eventnum" style="border-radius:40%;color:#FFFFFF;background-color:#FF0000;position:absolute;left:55%;" __cid="cyMRBBz" class="cyMRBBz"></p> 
            </span>  
            <p __cid="cyMRBBz" class="cyMRBBz">报警信息</p> 
          </li>  
          <li __cid="cyMRBBz" class="cyMRBBz" data-bind="event:{click:$model._callModelFn.bind($model, 'li2Click')}"> 
            <span class="contact cyMRBBz" __cid="cyMRBBz"></span>  
            <p __cid="cyMRBBz" class="cyMRBBz">关于</p> 
          </li> 
        </ul> 
      </nav>
    </div>
    <style __cid="cyMRBBz" class="cyMRBBz">.x-panel.pcviayya-iosstatusbar >.x-panel-top {height: 43px;}.x-panel.pcviayya-iosstatusbar >.x-panel-content { top: 43px;bottom: 67px;}.x-panel.pcviayya-iosstatusbar >.x-panel-bottom {height: 67px;}.iosstatusbar .x-panel.pcviayya-iosstatusbar >.x-panel-top,.iosstatusbar .x-panel .x-panel-content .x-has-iosstatusbar.x-panel.pcviayya-iosstatusbar >.x-panel-top {height: 63px;}.iosstatusbar .x-panel.pcviayya-iosstatusbar >.x-panel-content,.iosstatusbar .x-panel .x-panel-content .x-has-iosstatusbar.x-panel.pcviayya-iosstatusbar >.x-panel-content { top: 63px;}.iosstatusbar .x-panel .x-panel-content .x-panel.pcviayya-iosstatusbar >.x-panel-top {height: 43px;}.iosstatusbar .x-panel .x-panel-content .x-panel.pcviayya-iosstatusbar >.x-panel-content {top: 43px;}</style>
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
        <script src="../system/core.min.js"></script><script src="../system/common.min.js"></script><script src="../system/components/comp.min.js"></script><script id="_mainScript">
        
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
    				context.model = '$model/UI2/app/main.w' + (document.location.search || "");
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

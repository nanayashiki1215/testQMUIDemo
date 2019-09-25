/*! 
* WeX5 v3 (http://www.justep.com) 
* Copyright 2015 Justep, Inc.
* Licensed under Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0) 
*/ 
define(function(require) {
	var $ = require("jquery");
	var justep = require("$UI/system/lib/justep");
	//var Model = justep.ModelBase;
	var url = require.normalizeName("./windowOpener");
	var ComponentConfig = require("./windowOpener.config");
	window.__justep.windowOpeners = {};
	
	var WindowOpener = justep.BindComponent.extend({
		getConfig : function() {
			return ComponentConfig;
		},
		constructor : function(option) {
			this.id = option.id ? option.id : (new justep.UUID()).valueOf();
			this.url = option.url;
			this.windowId = this.id + "_window";
			this.process = option.process;
			this.activity = option.activity;
			this.executor = null;
			this.executorContext = null;
			this.window = null;
			this.modal = !!option.modal;
			this.status = option.status;
			this.width = option.width;
			this.height = option.height;
			this.left = option.left;
			this.top = option.top;
			this.resizable = !!option.resizable;
			this.parameters = option.parameters?option.parameters:'';
			this.isOverlaid = false;

			var f;
			if(typeof this.width=="string"){
				try{
					this.width = parseInt(this.width);
				}catch(e){
					var msg = new justep.Message(justep.Message.JUSTEP231047,"width",this.width);
					throw justep.Error.create(msg);
				}
			}
			if(typeof this.height=="string"){
				try{
					this.height = parseInt(this.height);
				}catch(e){
					var msg = new justep.Message(justep.Message.JUSTEP231047,"height",this.height);
					throw justep.Error.create(msg);
				}
			}

			if (option.onSend && option.onSend !== "") {
				f = null;
				try {
					f = eval(option.onSend);
				} catch (e) {
				}
				if (f && typeof f == "function") {
					this.on("onSend", f, this);
				}
			}

			if (option.onReceive && option.onReceive !== "") {
				f = null;
				try {
					f = eval(option.onReceive);
				} catch (e) {
				}
				if (f && typeof f == "function") {
					this.on("onReceive", f, this);
				}
			}

			if (option.onClose && option.onClose !== "") {
				f = null;
				try {
					f = eval(option.onClose);
				} catch (e) {
				}
				if (f && typeof f == "function") {
					this.on("onClose", f, this);
				}
			}

			if (option.onOpen && option.onOpen !== "") {
				f = null;
				try {
					f = eval(option.onOpen);
				} catch (e) {
				}
				if (f && typeof f == "function") {
					this.on("onOpen", f, this);
				}
			}
			
			
			this.callParent(option);
		},
		dispose : function() {
			this.close();
			this.callParent();
		},
		doInit : function(value, bindingContext) {
			this.callParent(value, bindingContext);
		}
		
	});
	
	/**
	 * 向弹出的窗口发送数据
	 */
	WindowOpener.prototype.sendToWindow = function(params) {
		var b = false;
		try{//沉默跨域的url
			b = !!this.window;
		}catch(e){}
		if (b && this.window) {
			//为了兼容旧的写法，很变态
			var lparams = params!==undefined?params:this.sendParam;
			var ldata = params!==undefined?(params?params.data:undefined):this.sendData;
			if(!params) params = {};
			var evtData = {
					source : this,
					data : ldata,
					params: lparams
			};
			this.fireEvent("onSend", evtData);
			if(evtData.params && evtData.params.data!==evtData.data) evtData.params.data = evtData.data;
			this.setParams(evtData.params);
			return evtData.params;
		}
	};
	
	WindowOpener.prototype.setURL = function(url) {
		this.url = url;
		this.window = null;
	};

	WindowOpener.prototype.getWindow = function() {
		return this.window;
	};

	WindowOpener.prototype._getParams = function(){
		var left = this.left, top = this.top, height = this.height, width = this.width,s;
		if(left===null || left===undefined || left==='') left = (window.screen.availWidth - width)/2;  
		if(top===null || top===undefined || top==='') top = (window.screen.availHeight - height)/2; 
		if(justep.Browser.IE){
			s = (this.modal?'modal=1,':'')
			+ (width?'width='+width+',':'')
			+ (height?'height='+height+',':'')
			+ (left!==null?'left='+left+',':'')
			+ (top!==null?'top='+top+',':'')
			+ (this.status=='fullscreen'?'channelmode=1,fullscreen=1,':'')
			+ (this.resizable?'resizable=1,':'')
			+ 'depended=1,z-look=1,location=0,'
			+ this.parameters;
			return s;
		}else{
			if(this.status=='fullscreen'){//计算全屏
				height = window.screen.availHeight - 60;
				width = window.screen.availWidth - 10;
				top = 0;
				left = 0;
			}
			s = (this.modal?'modal=1,':'')
			+ (width?'width='+width+',':'')
			+ (height?'height='+height+',':'')
			+ (left!==null?'left='+left+',':'')
			+ (top!==null?'top='+top+',':'')
			+ (this.status=='fullscreen'?'channelmode=1,fullscreen=1,':'')
			+ (this.resizable?'resizable=1,':'')
			+ 'depended=1,z-look=1,location=0,'
			+ this.parameters;
			return s;
		}
	};

	WindowOpener.prototype._getUrl = function(){
		var url = new justep.URL(this.url);
		url.setParam("$ownerid", this.id);
		if(this.process) url.setParam("process", this.process);
		if(this.activity) url.setParam("activity", this.activity);
		if(this.executor) url.setParam("executor", this.executor);
		if(this.executorContext) url.setParam("executorContext", this.executorContext);

		return require.toUrl(url.toString());
	};

	WindowOpener.prototype.createOverlay = function(){
	    var isIE6 = typeof document.body.style.maxHeight === "undefined";
		var sizeOverlay = function(){
			var $ModalOverlay = $('#ModalOverlay');
			if(isIE6){
				var overlayViewportHeight = document.documentElement.offsetHeight + document.documentElement.scrollTop - 4;
				var overlayViewportWidth = document.documentElement.offsetWidth - 21;
				$ModalOverlay.css({'height':overlayViewportHeight +'px','width':overlayViewportWidth+'px'});
			}else{
				$ModalOverlay.css({'height':'100%','width':'100%','position':'fixed'});
			}	
		};
		
		var sizeIE6Iframe = function(){
			var overlayViewportHeight = document.documentElement.offsetHeight + document.documentElement.scrollTop - 4;
			var overlayViewportWidth = document.documentElement.offsetWidth - 21;
			$('#ModalOverlayIE6FixIframe').css({'height':overlayViewportHeight +'px','width':overlayViewportWidth+'px'});
		};
		
	    var overlayColor = '#C1C1C1', overlayOpacity = 30;
	    $('body').append('<div id="ModalOverlay" style="z-index:10000;display:none;position:absolute;top:0;left:0;background-color:'+overlayColor+';filter:alpha(opacity='+overlayOpacity+');-moz-opacity: 0.'+overlayOpacity+';opacity: 0.'+overlayOpacity+';"></div>');
	    
	    if(isIE6){// if IE 6
	    	$('body').append('<iframe id="ModalOverlayIE6FixIframe"  src="about:blank"  style="width:100%;height:100%;z-index:9999;position:absolute;top:0;left:0;filter:alpha(opacity=0);"></iframe>');
	    	sizeIE6Iframe();
	    }
	    this.isOverlaid = true;
	    sizeOverlay();
	    var $ModalOverlay = $('#ModalOverlay');
	    $ModalOverlay.fadeIn('fast');
	};

	WindowOpener.prototype.removeOverlay = function(){
		$('#ModalOverlayIE6FixIframe').remove();
		$('#ModalOverlay').remove();
		this.isOverlaid = false;
	};

	WindowOpener.prototype.open = function(options) {
		this.sendParam = undefined;
		this.sendData = undefined;
		if(options){
			var data = options?options.data:undefined;
			var params = (options&&options.params)?options.params:{};
			if(!params.data) params.data = data;
			this.sendParam = params;
			this.sendData = params.data;
			if(options.title)	this.setTitle(options.title);
			if(options.process) this.setProcess(options.process);
			if(options.activity) this.setActivity(options.activity);
			if(options.executor) this.setExecutor(options.executor);
			if(options.executorContext) this.setExecutorContext(options.executorContext);
			if(options.url) this.setURL(options.url);
		}

		window.__justep.windowOpeners[this.id] = this;
		this.windowOpen(this._getUrl(), this.windowId, this._getParams());
		this.fireEvent("onOpen",{
			source : this,
			'window' : this.window//微信下目前不支持此属性
		});
	};
	
	WindowOpener.prototype.windowOpen = function(url,id,params){
		//打开窗口
		if(!justep.Browser.isWeChat){
			this.window = window.open(url,id,params);
			//this.window.location.href = this._getUrl();
			if(this.modal && !this.isOverlaid) this.createOverlay();
		}else{//微信特殊处理
			$('body').append('<iframe id="'+id+'" class="x-wechat-openwin" src="'+url+'"  style="width:100%;height:100%;z-index:9999;position:absolute;top:0;left:0;background-color: white;border: none;"></iframe>');
		}
	};
	
	WindowOpener.prototype.setParams = function(params){
		if(this.window && this.window.__justep && $.isFunction(this.window.__justep.setParams))
			this.window.__justep.setParams(params);
	};

	WindowOpener.prototype.dispatchCloseEvent = function(){
		var self = this;
		if(!justep.Browser.isWeChat){
			window.setTimeout(function(){
				if(!self.window || (self.window && self.window.closed)){
					if (self.isOverlaid) self.removeOverlay();
					self.fireEvent("onClose", {
						source : self
					});
				}
			}, 200);
		}else{
			self.fireEvent("onClose", {
				source : self
			});
		}
	};

	WindowOpener.prototype.close = function() {
		if(this.window){
			if(!justep.Browser.isWeChat){
				this.window.close();
				this.window = null;
			}else{
				$('body').children("#"+this.windowId).remove();
				this.window = null;
			}
		}
	};

	/**
	 * 确定 接收从window获得的数据
	 */
	WindowOpener.prototype.send = function(data) {
		this.fireEvent("onReceive", {
			source : this,
			data : data
		});
	};

	WindowOpener.prototype.refresh = function() {
		this.open();	
	};

	/**
	 * 取消
	 */
	WindowOpener.prototype.cancel = function() {
		this.close();
	};
	
	/**
	 * 是否允许拖拽改变大小
	 */
	WindowOpener.prototype.setResizable = function(flag) {
		this.resizable = flag;
	};

	WindowOpener.prototype.setExecutor = function(executor) {
		this.executor = executor;
	};

	WindowOpener.prototype.setExecutorContext = function(executorContext) {
		this.executorContext = executorContext;
	};

	WindowOpener.prototype.setProcess = function(process) {
		this.process = process;
	};

	WindowOpener.prototype.setActivity = function(activity) {
		this.activity = activity;
	};

	WindowOpener.prototype.getExecutor = function() {
		return this.executor;
	};

	WindowOpener.prototype.getExecutorContext = function() {
		return this.executorContext;
	};

	WindowOpener.prototype.getProcess = function() {
		return this.process;
	};

	WindowOpener.prototype.getActivity = function() {
		return this.activity;
	};
	
	justep.Component.register(url,WindowOpener);
	return WindowOpener;
});





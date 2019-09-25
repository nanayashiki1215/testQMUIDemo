define(function(require){
	var $ = require("jquery");
	var justep = require("$UI/system/lib/justep");
	
	var Model = function(){
		this.callParent();
	};
	$(".signaleventwindow").click(function(e){
	     e.stopPropagation();
		});
	Model.prototype.windowReceiver1Receive = function(event){
			var starttime = $(this.getElementByXid('starttime'));
			var metername=$(this.getElementByXid('metername'));
			var paramname=$(this.getElementByXid('paramname'));
			var value=$(this.getElementByXid('value'));
			var alarmtype=$(this.getElementByXid('alarmtype'));
			var alarmdesc=$(this.getElementByXid('alarmdesc'));
			starttime.text(event.data.starttime);
			metername.text(event.data.metername);
			paramname.text(event.data.paramname);
			value.text(event.data.value);
			if(event.data.paramname == "门禁"){
				if(event.data.value == "1"){
					alarmtype.text("开门");
					alarmdesc.text(event.data.alarmdesc).append("当前状态为开门");
				}if(event.data.value == "0"){
					alarmtype.text("关门");
					alarmdesc.text(event.data.alarmdesc).append("当前状态为关门");
				}
			}else{
				alarmtype.text(event.data.alarmtype);
			    alarmdesc.text(event.data.alarmdesc);
			}
			//alarmtype.text(event.data.alarmtype);
			//alarmdesc.text(event.data.alarmdesc);
	};

	return Model;
});
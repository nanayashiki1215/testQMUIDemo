define(function(require) {
	var $ = require("jquery");
	var justep = require("$UI/system/lib/justep");

	var Model = function() {
		this.callParent();
	};
	$(".overlimiteventwindow").click(function(e) {
		e.stopPropagation();
	});
	Model.prototype.windowReceiver1Receive = function(event) {
		var starttime = $(this.getElementByXid('starttime'));
		var endtime = $(this.getElementByXid('endtime'));
		var metername = $(this.getElementByXid('metername'));
		var paramname = $(this.getElementByXid('paramname'));
		var value = $(this.getElementByXid('value'));
		var limitvalue = $(this.getElementByXid('limitvalue'));
		var alarmtype = $(this.getElementByXid('alarmtype'));
		var alarmdesc = $(this.getElementByXid('alarmdesc'));
		starttime.text(event.data.starttime);
		endtime.text(event.data.endtime);
		metername.text(event.data.metername);
		paramname.text(event.data.paramname);
		value.text(event.data.value);
		limitvalue.text(event.data.limitvalue);
		alarmtype.text(event.data.alarmtype);
		alarmdesc.text(event.data.alarmdesc);
	};

	return Model;
});
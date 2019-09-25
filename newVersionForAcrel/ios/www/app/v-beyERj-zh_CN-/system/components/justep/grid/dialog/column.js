/*! 
* WeX5 v3 (http://www.justep.com) 
* Copyright 2015 Justep, Inc.
* Licensed under Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0) 
*/ 
define(function(require) {
	var $ = require("jquery");
	var Data = require("$UI/system/components/justep/data/data");

	var Model = function() {
		this.callParent();
	};
	
	/**
	 * 获取返回值，点击确定后调用的方法,必须是一个json格式的数据 .
	 */
	Model.prototype.getReturnValue = function(){
		var cols = [], data = this.comp('data');
		data.each(function(param){
			var col = {name:param.row.val('name')};
			if(col.name!=='rn'&&col.name!=='cb'){
				var disp = param.row.val('displayName');
				if(disp) col.displayName = disp; 
				col.show = data.getValue('selected', param.row);
				cols.push(col);
			}
		});
		return cols; 
	};
	
	Model.prototype.modelLoad = function(event) {
	};

	Model.prototype.checkbox2Change = function(event){
		var data = this.comp("data");
		data.each(function(param){
			param.row.val('selected',event.checked);
		});
	};

	Model.prototype.modelParamsReceive = function(event){
		this._cols = event.params.data;
		this.comp("data").refreshData();
	};

	Model.prototype.dataCustomRefresh = function(event){
		var cols = this._cols;
		if ($.isArray(cols)) {
			var datas = [];
			$.each(cols, function(i, col){
				if(col.name!=='rn'&&col.name!=='cb')
					datas.push({name:col.name, displayName:col.label||col.name, selected:!col.hidden});
			});
			event.source.loadData(datas);
		}
	};

	Model.prototype.btnOKClick = function(event){
		this.owner.send(this.getReturnValue());
		this.owner.close();
	};

	Model.prototype.btnFirstClick = function(event){
		var data = this.comp("data");
		var row1 = event.bindingContext.$object;
		if(!(row1 instanceof Data.Row)) row1 = data.getCurrentRow(true);
		data.moveRowTo(row1, data.getFirstRow());
	};

	Model.prototype.btnLastClick = function(event){
		var data = this.comp("data");
		var row1 = event.bindingContext.$object;
		if(!(row1 instanceof Data.Row)) row1 = data.getCurrentRow(true);
		data.moveRowTo(row1, data.getLastRow());
	};

	Model.prototype.move = function(row, up){
		if(row){
			var data = this.comp('data');
			var index = data.getRowIndex(row);
			index += (up?-1:1);
			if(index<0 || index>=data.getCount()) return;
			var datas = data.datas.peek();
			var row2 = datas[index];
			data.exchangeRow(row,row2);
		}
	};

	Model.prototype.btnPrevClick = function(event){
		var data = this.comp("data");
		var row1 = event.bindingContext.$object;
		if(!(row1 instanceof Data.Row)) row1 = data.getCurrentRow(true);
		this.move(row1,true);
	};

	Model.prototype.btnNextClick = function(event){
		var data = this.comp("data");
		var row1 = event.bindingContext.$object;
		if(!(row1 instanceof Data.Row)) row1 = data.getCurrentRow(true);
		this.move(row1);
	};

	return Model;
});
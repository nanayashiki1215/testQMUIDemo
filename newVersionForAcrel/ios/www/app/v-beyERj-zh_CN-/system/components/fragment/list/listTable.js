/*! 
* X5 v3 (http://www.justep.com) 
* Copyright 2014 Justep, Inc.
* Licensed under Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0) 
*/ 
define(function(require) {
	require("$UI/system/components/justep/common/res");

	//var $ = require("jquery");
	var justep = require('$UI/system/lib/justep');
	var Data = require("$UI/system/components/justep/data/data");

	var url = require.normalizeName("./listTable");
	var ComponentConfig = require("./listTable.config");

	var ListTable = justep.BindComponent.extend({
		getConfig : function() {
			return ComponentConfig;
		},
		getUrl : function() {
			return url;
		},
		// 构造函数
		constructor : function(options) {
			this.callParent(options);
		},
		doInit : function(value, bindingContext) {
			
		}
	});
	
	var doNewDataEvent = function(model,masterDataxid,filterCol,event){
		var rows = event.table;
		var masterData = model.comp(masterDataxid);
		var crow = masterData.getCurrentRow(true);
		if(crow){
			if(0===rows.length){
				var row = {};
				row[filterCol] = crow.getID();
				rows.push(row);
			}else{
				$.each(rows,function(i,row){
					row[filterCol] = crow.getID();
				});
			}
		}
	};
	
	var doMasterDataAfterRefresh = function(model,dataxid,filterCol,event){
		var searchData = model.comp(dataxid);
		var searchFilters = [];
		var rows = event.source.getChildren();
		var defCol = searchData.defCols[filterCol];
		var parentRelation = defCol.relation;
		var type = defCol.type;
		for(var i=0; i<rows.length; i++){
			searchFilters.push(parentRelation + '=' + justep.Util.toExprString(type, rows[i].getID(), true));
		}
		if(searchFilters.length>0){
			searchData.setFilter('_search_root_filter_', searchFilters.join(' OR '));
			searchData.refreshData({async:true});
		}
	};
	
	ListTable.dataEventBind = function(model,masterDataxid,dataxid,filterCol){
		if(masterDataxid){
			var masterData = model.comp(masterDataxid);
			if(masterData){
				var data = model.comp(dataxid);
				if(filterCol){
					masterData.on(Data.EVENT_REFRESHDATA_AFTER,doMasterDataAfterRefresh.bind(this,model,dataxid,filterCol));
					if(data){
						data.setFilter('_search_root_filter_','1=2');
						data.limit = -1;
					}
				}
				if(data){
					data.on(Data.EVENT_NEWDATA_CREATEPARAM,doNewDataEvent.bind(this,model,masterDataxid,filterCol));
				}
			}
		}
	};
	
	justep.Component.register(url, ListTable);
	return ListTable;
});

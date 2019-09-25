/*! 
 * WeX5 v3 (http://www.justep.com) 
 * Copyright 2015 Justep, Inc.
 * Licensed under Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0) 
 */
define(function(require) {
	var justep = require('$UI/system/lib/justep');
	var Expr = justep.Express;

	require('$UI/system/resources/system.res');

	var DataFilter = justep.Object.extend({
		setFilter: function(filter){
			this.filter = filter;
			var filterExpr = null;
			if (filter && 'string' == typeof (filter))
				filterExpr = new Expr(filter);
			this._setFilterExpr(filterExpr);
		},
		getFilter: function(){
			return this.filter;
		},
		_setFilterExpr : function(expr){
			if(!this._filterExpr) this._filterExpr = justep.Bind.observable();
			this._filterExpr.set(expr);
		},
		_getFilterExper : function(){
			if(!this._filterExpr){
				var filterExpr;
				if (this.filter && 'string' == typeof (this.filter))
					filterExpr = new Expr(this.filter);
				this._filterExpr = justep.Bind.observable(filterExpr);
			}
			return this._filterExpr.get();
		},
		doFilter: function(allItems){
			var ret = [];
			var eventData;

			if(!this.hasListener('onCustomFilter')){
				var filterExpr = this._getFilterExper();
				if (filterExpr instanceof Expr){
					var ctx = justep.Bind.contextFor(this.domNode);
					for ( var i = 0; i < allItems.length; i++) {
						var current = allItems[i];
						ctx.$row = current;
						if (Expr.eval(filterExpr, current, ctx))
							ret.push(current);
						delete ctx.$row;
					}
				}else ret = allItems;
			}else{
				eventData = {
						source : this,
						datas: allItems
					};
				this.fireEvent('onCustomFilter', eventData);
				ret = eventData.datas;
			}
			
			eventData = {
					source : this,
					datas: ret
				};
			this.fireEvent('onFilter', eventData);
			ret = eventData.datas;

			return ret;
		}		
	});

	return DataFilter;
});
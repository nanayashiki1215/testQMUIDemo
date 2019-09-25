cordova.define("com.justep.cordova.plugin.baidulocation.geolocationExtends", function(require, exports, module) {
var PI = 3.1415926535897932384626;
var a = 6378245.0;
var ee = 0.00669342162296594323;
var x_PI = 3.14159265358979324 * 3000.0 / 180.0;
/**
 * 判断是否在国内，不在国内则不做偏移
 *
 * @param lng
 * @param lat
 * @returns {boolean}
 */
var realCurrentPosition = navigator.geolocation.getCurrentPosition;


function out_of_china(lng, lat) {
    return (lng < 72.004 || lng > 137.8347) || ((lat < 0.8293 || lat > 55.8271) || false);
};

function transformlat(lng, lat) {
    var ret = -100.0 + 2.0 * lng + 3.0 * lat + 0.2 * lat * lat + 0.1 * lng * lat + 0.2 * Math.sqrt(Math.abs(lng));
    ret += (20.0 * Math.sin(6.0 * lng * PI) + 20.0 * Math.sin(2.0 * lng * PI)) * 2.0 / 3.0;
    ret += (20.0 * Math.sin(lat * PI) + 40.0 * Math.sin(lat / 3.0 * PI)) * 2.0 / 3.0;
    ret += (160.0 * Math.sin(lat / 12.0 * PI) + 320 * Math.sin(lat * PI / 30.0)) * 2.0 / 3.0;
    return ret
};

function transformlng(lng, lat) {
    var ret = 300.0 + lng + 2.0 * lat + 0.1 * lng * lng + 0.1 * lng * lat + 0.1 * Math.sqrt(Math.abs(lng));
    ret += (20.0 * Math.sin(6.0 * lng * PI) + 20.0 * Math.sin(2.0 * lng * PI)) * 2.0 / 3.0;
    ret += (20.0 * Math.sin(lng * PI) + 40.0 * Math.sin(lng / 3.0 * PI)) * 2.0 / 3.0;
    ret += (150.0 * Math.sin(lng / 12.0 * PI) + 300.0 * Math.sin(lng / 30.0 * PI)) * 2.0 / 3.0;
    return ret
};
/**
 * 百度坐标系 (BD-09) 与 火星坐标系 (GCJ-02)的转换 即 百度 转 谷歌、高德
 *
 * @param bd_lon
 * @param bd_lat
 * @returns {*[]}
 */
function bd09lltogcj02(bd_lon, bd_lat) {
    var x_pi = 3.14159265358979324 * 3000.0 / 180.0;
    var x = bd_lon - 0.0065;
    var y = bd_lat - 0.006;
    var z = Math.sqrt(x * x + y * y) - 0.00002 * Math.sin(y * x_pi);
    var theta = Math.atan2(y, x) - 0.000003 * Math.cos(x * x_pi);
    var gg_lng = z * Math.cos(theta);
    var gg_lat = z * Math.sin(theta);
    return [gg_lng, gg_lat]
};

/**
 * 火星坐标系 (GCJ-02) 与百度坐标系 (BD-09) 的转换 即谷歌、高德 转 百度
 *
 * @param lng
 * @param lat
 * @returns {*[]}
 */
function gcj02tobd09ll(lng, lat) {
    var z = Math.sqrt(lng * lng + lat * lat) + 0.00002 * Math.sin(lat * x_PI);
    var theta = Math.atan2(lat, lng) + 0.000003 * Math.cos(lng * x_PI);
    var bd_lng = z * Math.cos(theta) + 0.0065;
    var bd_lat = z * Math.sin(theta) + 0.006;
    return [bd_lng, bd_lat]
};

/**
 * WGS84转GCj02
 *
 * @param lng
 * @param lat
 * @returns {*[]}
 */
function wgs84togcj02(lng, lat) {
    if (out_of_china(lng, lat)) {
        return [lng, lat]
    } else {
        var dlat = transformlat(lng - 105.0, lat - 35.0);
        var dlng = transformlng(lng - 105.0, lat - 35.0);
        var radlat = lat / 180.0 * PI;
        var magic = Math.sin(radlat);
        magic = 1 - ee * magic * magic;
        var sqrtmagic = Math.sqrt(magic);
        dlat = (dlat * 180.0) / ((a * (1 - ee)) / (magic * sqrtmagic) * PI);
        dlng = (dlng * 180.0) / (a / sqrtmagic * Math.cos(radlat) * PI);
        var mglat = lat + dlat;
        var mglng = lng + dlng;
        return [mglng, mglat]
    }
};

/**
 * GCJ02 转换为 WGS84
 *
 * @param lng
 * @param lat
 * @returns {*[]}
 */
function gcj02towgs84(lng, lat) {
    if (out_of_china(lng, lat)) {
        return [lng, lat]
    } else {
        var dlat = transformlat(lng - 105.0, lat - 35.0);
        var dlng = transformlng(lng - 105.0, lat - 35.0);
        var radlat = lat / 180.0 * PI;
        var magic = Math.sin(radlat);
        magic = 1 - ee * magic * magic;
        var sqrtmagic = Math.sqrt(magic);
        dlat = (dlat * 180.0) / ((a * (1 - ee)) / (magic * sqrtmagic) * PI);
        dlng = (dlng * 180.0) / (a / sqrtmagic * Math.cos(radlat) * PI);
        mglat = lat + dlat;
        mglng = lng + dlng;
        return [lng * 2 - mglng, lat * 2 - mglat]
    }
};

function regroupdata(jsonObj, loc, coordtype, errorCallback) {
    try {
        // 增加坐标类型
        if (cordova.platformId === 'android') {
            var result = new Object();
            result.coords = new Object(); // 作为对象属性的，嵌套对象
            result.coords.longitude = loc[0];
            result.coords.latitude = loc[1];
            result.coorType = coordtype;
            return result;
        } else {
            // 增加坐标类型
            var pos = new Position({
                latitude: loc[1],
                longitude: loc[0],
                altitude: jsonObj.coords.altitude,
                accuracy: jsonObj.coords.accuracy,
                heading: jsonObj.coords.heading,
                velocity: jsonObj.coords.velocity,
                altitudeAccuracy: jsonObj.coords.altitudeAccuracy,
                coordtype: coordtype
            }, (jsonObj.timestamp === undefined ? new Date() : ((jsonObj.timestamp instanceof Date) ? jsonObj.timestamp : new Date(jsonObj.timestamp))));
            return pos;
        }
    } catch (e) {
        errorCallback(e);
    }
};

function regrouploc(loc, coordtype, errorCallback) {
    try {
        var result = new Object();
        result.coords = new Object(); // 作为对象属性的，嵌套对象
        result.coords.longitude = loc[0];
        result.coords.latitude = loc[1];
        result.coorType = coordtype;
        return result;
    } catch (e) {
        errorCallback(e);
    }
}
var geolocationExtends = {

    transformPosition: function(params) {
        var loc, postrans;
        var fromCoordinateType = params.fromCoordinateType;
        var toCoordinateType = params.toCoordinateType;
        var longitude = params.longitude;
        var latitude = params.latitude;
        var successCallback;
        if (params.successCallback) {
            successCallback = params.successCallback;
        };
        var errorCallback;
        if (params.errorCallback) {
            errorCallback = params.errorCallback;
        };
        if (fromCoordinateType == "bd09ll" && toCoordinateType == "wgs84") {
            loc = bd09lltogcj02(longitude, latitude);
            loc = gcj02towgs84(loc[0], loc[1]);
        } else if (fromCoordinateType == "bd09ll" && toCoordinateType == "gcj02") {

            loc = bd09lltogcj02(longitude, latitude);
        } else if (fromCoordinateType == "gcj02" && toCoordinateType == "bd09ll") {

            loc = gcj02tobd09ll(longitude, latitude);
        } else if (fromCoordinateType == "gcj02" && toCoordinateType == "wgs84") {

            loc = gcj02towgs84(longitude, latitude);
        } else if (fromCoordinateType == "wgs84" && toCoordinateType == "gcj02") {

            loc = wgs84togcj02(longitude, latitude);
        } else if (fromCoordinateType == "wgs84" && toCoordinateType == "bd09ll") {

            loc = wgs84togcj02(longitude, latitude);
            loc = gcj02tobd09ll(loc[0], loc[1]);
        } else if (fromCoordinateType == toCoordinateType) {
            loc = [longitude, latitude];
        }
        if ((toCoordinateType == "bd09ll" || toCoordinateType == "gcj02" || toCoordinateType == "wgs84") &&
            (fromCoordinateType == "bd09ll" || fromCoordinateType == "gcj02" || fromCoordinateType == "wgs84")) {
            var postrans = regrouploc(loc, toCoordinateType, errorCallback);
            if ("undefined" != typeof(postrans) && typeof(postrans) != null) {
                if (params.successCallback) {
                    params.successCallback(postrans);
                }
                return postrans;
            }
        } else {
            if (params.errorCallback) {
                params.errorCallback("错误的转换类型,仅支持bd09ll、gcj02、wgs84的相互转换");
            }

            return;
        }

    },
    transform: function(successCallback, errorCallback, longitude, latitude, fromCoordinateType, toCoordinateType) {
        var params = {};
        var loc;
        if (successCallback) {
            params.successCallback = successCallback;
        };
        if (errorCallback) {
            params.errorCallback = errorCallback;
        }
        params.longitude = longitude;
        params.latitude = latitude;
        params.fromCoordinateType = fromCoordinateType;
        params.toCoordinateType = toCoordinateType;
        loc = this.transformPosition(params);
        return loc;

    },
    _compationParams: function(options, type) {
        if (type) {
            options = options || {};
            options.type = type;
        }
        return options;
    },

    _getCurrentPosition: function(successCallback, errorCallback, options, type) {
        options = this._compationParams(options, type);
        var self = this;
        if (navigator.baiduLocation) {
            realCurrentPosition = navigator.baiduLocation.getCurrentPosition;
        }
        realCurrentPosition.call(navigator.baiduLocation, function(result) {
            if (options && options.type) {
                var type = options.type;
                var resultCoords = self.transform(null, null, result.coords.longitude, result.coords.latitude, result.coorType || "wgs84", type);
                result.coords = resultCoords.coords;
                result.coorType = resultCoords.coorType;
            }
            if (result) {
                successCallback.call(navigator.geolocation, result);
            } else {
                errorCallback.call(navigator.geolocation, type);
            }
        }, errorCallback, options);
    },

    isGPSOpen: function(successCallback, errorCallback) {
        navigator.baiduLocation.isGPSOpen(successCallback, errorCallback);
    },

    enableGPS: function(successCallback, errorCallback) {
        navigator.baiduLocation.enableGPS(successCallback, errorCallback);
    },
               
    watchPosition:function(successCallback, errorCallback, options) {
        return navigator.baiduLocation.watchPosition(successCallback, errorCallback, options);
    },
        
    clearWatch:function(id) {
        navigator.baiduLocation.clearWatch(id);
    }
};

//定位增强
if (navigator.baiduLocation) {
    navigator.geolocation = navigator.baiduLocation;
}

//定位能力扩展 包装实现
if (navigator.geolocation) {
    navigator.geolocation.getCurrentPosition = function() {
        return navigator.geolocation._getCurrentPosition.apply(navigator.geolocation, arguments);
    };
}
module.exports = geolocationExtends;

});

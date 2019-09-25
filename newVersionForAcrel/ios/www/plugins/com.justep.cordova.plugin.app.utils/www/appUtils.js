cordova.define("com.justep.cordova.plugin.app.utils.AppUtils", function(require, exports, module) {
var exec = require('cordova/exec');
var appUtils = {
  needDeleteResource:true,
	options : {
		wifiDownloadOnly : true,
		quiet : false
	},
	isWifiConnection : function() {
		var networkState = navigator.connection.type;
		if (networkState == Connection.WIFI) {
			return true;
		}
		return false;
	},
	getIndexPageUrl : function(success, fail) {
		var x5Version = this.getAppVersion();
		try {
          var indexPageKey = "indexPage";
		  plugins.appPreferences.fetch(success, fail, indexPageKey);
    } catch (e5) {
    }
  },
  setIndexPageUrl : function(indexPageUrl) {
    //var x5Version = this.getAppVersion();
    try {
      if (window.__justep.url === indexPageUrl) {
        if(this.needDeleteResource){
          console.log("Delete unused resources!!!");
          this.needDeleteResource = false;
          this.deleteFiles(0);
        }
        return;
      }
      
      var indexPageKey = "indexPage";
      if (plugins && plugins.appPreferences) {
        plugins.appPreferences.store(function() {
          window.__justep.url = indexPageUrl;
          window.location.href=indexPageUrl;
          this.needDeleteResource = true;
        }, function() {
        }, indexPageKey, indexPageUrl);
      }
    } catch (e5) {
    }
  },
  getLocalResourceMd5 : function(success, fail) {
    var x5Version = this.getAppVersion();
    try {
      var resourceMd5Key = "resourceMd5_" + x5Version;
      plugins.appPreferences.fetch(success, fail, resourceMd5Key);
    } catch (e5) {
    }
  },
  setLocalResourceMd5 : function(md5) {
    var x5Version = this.getAppVersion();
    try {
      var resourceMd5Key = "resourceMd5_" + x5Version;
      if (plugins && plugins.appPreferences) {
        plugins.appPreferences.store(function() {
      }, function() {
      }, resourceMd5Key, md5);
      }
    } catch (e5) {
    }
  },
  getAppVersion : function() {
    var x5Version = "noApp";
    var x5AppAgents = /x5app\/([0-9.]*)/.exec(navigator.userAgent);
    if (x5AppAgents && x5AppAgents.length > 1) {
      x5Version = x5AppAgents[1] || "";
    }
    return x5Version;
  },

  getResourceDirPath : function() {
    if (window.__justep && window.__justep.versionInfo) {
      var baseUrl = window.__justep.versionInfo.baseUrl;
      var version = window.__justep.versionInfo.resourceInfo.version;
      return "www" + baseUrl.replace(location.protocol + "//" + location.host, "") + version;
    } else {
      return "www";
    }
  },

  getAssetsPath : function() {
    var self = this;
    var dfd = $.Deferred();
    window.resolveLocalFileSystemURL(cordova.file.dataDirectory + self.getResourceDirPath(), function(dirEntry) {
      var destDir = dirEntry.toURL();
      dfd.resolve(cordova.file.dataDirectory + "www/");
    }, function() {
      window.resolveLocalFileSystemURL(cordova.file.applicationDirectory + self.getResourceDirPath(), function(dirEntry) {
        var destDir = dirEntry.toURL();
        dfd.resolve(cordova.file.applicationDirectory + "www/");
      }, function() {
        dfd.resolve("");
      });
    });
    return dfd.promise();
  },

  checkAsset : function(path) {
    var dfd = $.Deferred();
    window.resolveLocalFileSystemURL(path, function(dirEntry) {
      dfd.resolve(true);
    }, function() {
      dfd.resolve(false);
    });
    return dfd.promise();
  },

  updateAppResource : function(resourceDownloadUrl) {
    if (!$.Deferred) {
      return;
    }
    var dfd = $.Deferred();
    var self = this;
    window.resolveLocalFileSystemURL(cordova.file.dataDirectory + self.getResourceDirPath(), function(dirEntry) {
      var destDir = dirEntry.toURL();
      dfd.resolve(destDir);
    }, function() {
      if (self.options.wifiDownloadOnly && !self.isWifiConnection()) {
        if (!self.options.quiet) {
          plugins.toast.showShortBottom("当前不是wifi环境已经阻止资源包自动更新!等待下次自动更新");
        }
        dfd.reject("only download in wifi");
      } else {
        window.resolveLocalFileSystemURL(cordova.file.dataDirectory, function(dirEntry) {
          var ft = new FileTransfer();
          /**
           * ft.onprogress = function(progressEvent) { if
           * (progressEvent.lengthComputable) { var percentage =
           * Math.floor(progressEvent.loaded / progressEvent.total *
           * 100) + "%"; } };
           */
          ft.download(resourceDownloadUrl, dirEntry.toURL() + "www.zip", function(entry) {
        	  
           if (!self.options.quiet) {
              plugins.toast.showShortBottom("开始下载离线资源包!");
            }
           
            var zipFileUrl = entry.toURL();
            var destDir = dirEntry.toURL();
            zip.unzip(zipFileUrl, destDir, function(code) {
              if (code === 0) {
                var path = cordova.file.dataDirectory + self.getResourceDirPath();
                window.resolveLocalFileSystemURL(cordova.file.dataDirectory + self.getResourceDirPath(), function(dirEntry) {
                  if (!self.options.quiet) {
                    plugins.toast.showLongBottom("离线资源已经下载并安装成功!");
                  }
                  dfd.resolve(destDir);
                }, function() {
                  if (!self.options.quiet) {
                    plugins.toast.showShortBottom("资源包校验失败!未找到" + path + "对应目录");
                  }
                  dfd.reject();
                });
              } else {
                dfd.reject(code);
              }
            });
          }, function(err) {
            dfd.reject(err.code);
          });
        }, function(error) {
          dfd.reject(error.code);
        });
      }
    });
    return dfd.promise();
  },
  updateAppMd5Resource : function(resourceDownloadUrl) {
    if (!$.Deferred) {
      return;
    }
    var dfd = $.Deferred();
    var self = this;
    if (self.options.wifiDownloadOnly && !self.isWifiConnection()) {
      if (!self.options.quiet) {
        plugins.toast.showShortBottom("当前不是wifi环境已经阻止资源包自动更新!等待下次自动更新");
      }
      dfd.reject("only download in wifi");
    } else {
    	
      window.resolveLocalFileSystemURL(cordova.file.dataDirectory, function(dirEntry) {
    	  
        if (!self.options.quiet) {
          plugins.toast.showShortBottom("开始下载离线资源包!");
        }
        
        var ft = new FileTransfer();
        ft.download(resourceDownloadUrl, dirEntry.toURL() + "www.zip", function(entry) {

          var zipFileUrl = entry.toURL();
          var destDir = dirEntry.toURL();
          zip.unzip(zipFileUrl, destDir, function(code) {
            if (code === 0) {
              var path = cordova.file.dataDirectory + self.getResourceDirPath();
              if (!self.options.quiet) {
                plugins.toast.showLongBottom("离线资源已经下载并安装成功!");
              }
              dfd.resolve(destDir);
            } else {
              dfd.reject(code);
            }
          });
        }, function(err) {
          if (!self.options.quiet) {
            plugins.toast.showShortBottom("资源包安装失败!");
          }
          dfd.reject(err.code);
        });
      }, function(error) {
        if (!self.options.quiet) {
          plugins.toast.showShortBottom("资源包下载失败!url:" + resourceDownloadUrl);
        }
        dfd.reject(error.code);
      });
    }
    return dfd.promise();
  },

  deleteFiles : function(type) {
    var self = this;
    var path;
    if (type == 0) {
      path = cordova.file.dataDirectory + self.getResourceDirPath();
      var versionInfo = window.__justep.versionInfo;
      var index = path.indexOf(versionInfo.resourceInfo.version);
      var temppath = path.substring(0, index - 1);
      console.log('temppath: ' + temppath);
      window.resolveLocalFileSystemURL(temppath, function(dirEntry) {
        var dirReader = dirEntry.createReader();
        dirReader.readEntries(function(entries) {
          for (var i = 0; i < entries.length; i++) {
            var entry = entries[i];
            if (entry.isDirectory) {
              //console.log("entry: nativeURL=" + entry.nativeURL);
              if (entry.name != versionInfo.resourceInfo.version) {
                console.log("remove dir:" + entry.nativeURL);
                entry.removeRecursively(null, null);
              }
            }
          }
        });
      }, null);

      window.resolveLocalFileSystemURL(cordova.file.dataDirectory, function(dirEntry) {
        var dirReader = dirEntry.createReader();
        var resourcezipfile = cordova.file.dataDirectory + "www.zip";
        console.log('resourcezipfile: ' + resourcezipfile);
        dirReader.readEntries(function(entries) {
          for (var i = 0; i < entries.length; i++) {
            var entry = entries[i];
            if (entry.isFile) {
              if (entry.nativeURL == resourcezipfile) {
                console.log("remove file:" + entry.nativeURL);
                entry.remove(null, null);
                break;
              }
            }
          }
        });
      }, null);
      return;
    }

    var u = navigator.userAgent, app = navigator.appVersion;
    var isAndroid = u.indexOf('Android') > -1 || u.indexOf('Linux') > -1; // android终端或者uc浏览器
    var isiOS = !!u.match(/\(i[^;]+;( U;)? CPU.+Mac OS X/); // ios终端
    if (isAndroid) {
      path = cordova.file.externalCacheDirectory;
    } else if (isiOS) {
      path = cordova.file.cacheDirectory;
    } else {
      path = fileSystem.root.toURL();
    }

    window.resolveLocalFileSystemURL(path, function(dirEntry) {
      // console.log('2---file system open: ' + dirEntry.nativeURL);
      var dirReader = dirEntry.createReader();
      dirReader.readEntries(function(entries) {
        for (var i = 0; i < entries.length; i++) {
          var entry = entries[i];
          if (entry.isFile) {
            console.log("remove file:" + entry.nativeURL);
            entry.remove(null, null);
          } else {
            console.log("remove dir:" + entry.nativeURL);
            entry.removeRecursively(null, null);
          }
        }
      });
    }, null);

    if (isiOS) {
      window.resolveLocalFileSystemURL(cordova.file.tempDirectory, function(dirEntry) {
        // console.log('3----file system open: ' +
        // dirEntry.nativeURL);
        var dirReader = dirEntry.createReader();
        dirReader.readEntries(function(entries) {
          for (var i = 0; i < entries.length; i++) {
            var entry = entries[i];
            if (entry.isFile) {
              console.log("remove file:" + entry.nativeURL);
              entry.remove(null, null);
            } else {
              console.log("remove dir:" + entry.nativeURL);
              entry.removeRecursively(null, null);
            }
          }
        });
      }, null);
    }

    if (isAndroid) {
      window.resolveLocalFileSystemURL(cordova.file.cacheDirectory, function(dirEntry) {
        // console.log('3----file system open: ' +
        // dirEntry.nativeURL);
        var dirReader = dirEntry.createReader();
        dirReader.readEntries(function(entries) {
          for (var i = 0; i < entries.length; i++) {
            var entry = entries[i];
            if (entry.isFile) {
              console.log("remove file:" + entry.nativeURL);
              entry.remove(null, null);
            } else {
              console.log("remove dir:" + entry.nativeURL);
              entry.removeRecursively(null, null);
            }
          }
        });
      }, null);
    }
  },

  clearCache : function(type) {
    if (!$.Deferred) {
      return;
    }

    var dfd = $.Deferred();
    var self = this;
    var requestFileSystemApi = window.webkitRequestFileSystem || window.requestFileSystem;

    if (window.cordova) {
      document.addEventListener('deviceReady', function() {
        self.deleteFiles(type);
        dfd.resolve(type);
      }, false);
    } else if (requestFileSystemApi) {
      self.deleteFiles(type);
      dfd.resolve(type);
    } else {
      dfd.reject({
        code : 0,
        msg : "not implement fileSystem"
      });
    }
    return dfd.promise();
  },
};
module.exports = appUtils;
});

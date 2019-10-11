$(function(){
  var storage = localStorage.getItem("accessToken");
  // storage = storage ? JSON.parse(storage):[];
  storage = JSON.parse(storage);
  var baserUrlFromIos = storage.baseurl;
  var tokenFromIos = storage.token;
  var subid1FromIos = Number(storage.fsubID);
  alert(subid1FromIos,baserUrlFromIos);
    //创建MeScroll对象
    var mescroll = new MeScroll("mescroll", {
        down: {
            auto: false, //是否在初始化完毕之后自动执行下拉回调callback; 默认true
            callback: downCallback //下拉刷新的回调
        },
        up: {
            auto: true, //是否在初始化时以上拉加载的方式自动加载第一页数据; 默认false
            callback: upCallback, //上拉回调,此处可简写; 相当于 callback: function (page) { upCallback(page); }
            empty: {
                tip: "暂无相关数据", //提示
            },
            clearEmptyId: "newsList" //相当于同时设置了clearId和empty.warpId; 简化写法;默认null
        }
    });

     /*初始化*/
    var type=0;
    var startDate;
    var endDate;
    var YandM;//Year and Month
    var today;//今天
    var lastDay;//最后一天
    var date = new Date();

    $(document).on('click','.selectcontain .btn',function () {
        $(this).addClass('select').siblings('button').removeClass('select');
        type=1;
        closeMenu();
        mescroll.resetUpScroll();
    });

    $(document).on('click','.search',function () {
        $('.btn').removeClass('select');
        type=2;
        closeMenu();
        mescroll.resetUpScroll();
    });
    
    /*下拉刷新的回调 */
    function downCallback(){
        //联网加载数据
        getListDataFromNet(1, 20, function(data){
            //联网成功的回调,隐藏下拉刷新的状态
            mescroll.endSuccess();
            //设置列表数据
            setListData(data,"refresh");
        }, function(){
            //联网失败的回调,隐藏下拉刷新的状态
            mescroll.endErr();
        });
    }
    
    /*上拉加载的回调 page = {num:1, size:10}; num:当前页 从1开始, size:每页数据条数 */
    function upCallback(page){
        getListDataFromNet(page.num, page.size, function(data){
            //联网成功的回调,隐藏下拉刷新和上拉加载的状态;
            mescroll.endSuccess(data.list.length);//传参:数据的总数; mescroll会自动判断列表如果无任何数据,则提示空;列表无下一页数据,则提示无更多数据;
            //设置列表数据
            setListData(data,"normal");
        }, function(){
            //联网失败的回调,隐藏下拉刷新和上拉加载的状态;
            mescroll.endErr();
        });
    }
    
    /*设置列表数据*/
    function setListData(data,type) {
        var listDom=document.getElementById("newsList");
    
        if(type=="refresh"){
            listDom.innerHTML='';
        }
        $(data.list).each(function () {
            var str = this.fStarttime +"<br>"+"[类型："+this.fAlarmtype+" 仪表名称："+this.fMetername
                +" 参数名称："+this.fParamname+"][报警值："+this.fValue+" 限定值："+this.fLimitvalue+
                "]"
            var liDom=document.createElement("li");
            liDom.innerHTML=str;
            listDom.appendChild(liDom);//加在列表的后面,上拉加载
        });
    }
    

    function getListDataFromNet(pageNum,pageSize,successCallback,errorCallback) {
       if(type==0){
            notLastMon();
            startDate = YandM+"-"+today;
            endDate = YandM+"-"+today;
            $(".startDate").val(startDate);
            $(".endDate").val(endDate);
            $(".timeContain").html(startDate);
        }
        if(type==1){
            var btnId = $('.btn.select').attr("id");
            switch(btnId){
                case "today":
                    notLastMon();
                    startDate = YandM+"-"+today;
                    endDate = YandM+"-"+today;
                    $(".timeContain").html(startDate);
                    break;
                case "yesterday":
                    notLastMon();
                    var yesterday = today-1;
                    startDate = YandM+"-"+yesterday;
                    endDate = YandM+"-"+yesterday;
                    $(".timeContain").html(startDate);
                    break;
                case "thisMon":
                    notLastMon();
                    startDate = YandM+"-"+"01";
                    endDate = YandM+"-"+today;
                    $(".timeContain").html(startDate+" 至 "+endDate);
                    break;
                case "lastMon":
                    lastMon();
                    startDate = YandM+"-"+"01";
                    endDate = YandM+"-"+lastDay;
                    $(".timeContain").html(startDate+" 至 "+endDate);
                    break;
            }
            $(".startDate").val(startDate);
            $(".endDate").val(endDate);
        }
        if(type==2){
            startDate =  $(".startDate").val();
            endDate = $(".endDate").val();
            $(".timeContain").html(startDate+" 至 "+endDate);
        }
        //开始时间不能大于截止时间
        if(startDate>endDate){
            $(".timeContain").html("请选择正确的查询时间！");
            return;
        }
        var fAlarmtype = $("#alermType").val();//类型
        var fMetername = $("#meterName").val();//仪表名称
        var fParamname = $("#paramName").val();//参数名称
  
        if(fAlarmtype=="全部"){
            var params={
                fSubid:subid1FromIos,
                startDate:startDate,
                endDate:endDate,
                fMetername:fMetername,
                fParamname:fParamname,
                pageNo:pageNum,
                pageSize:pageSize
            }
        }else{
            var params={
                fSubid:subid1FromIos,
                startDate:startDate,
                endDate:endDate,
                fAlarmtype:fAlarmtype,
                fMetername:fMetername,
                fParamname:fParamname,
                pageNo:pageNum,
                pageSize:pageSize
            };
        }
    
        try{
            var token = tokenFromIos;
  alert(token);
            $.ajax({
                type:'GET',
                url:"http://116.236.149.162:8090/SubstationWEBV2/main/app/eventLog/OverLimitEvent",
                data:params,
                beforeSend:function(request){
                    request.setRequestHeader("Authorization",token)
                },
                success:function(result){
                    successCallback&&successCallback(result.data);
                }
            })
        }catch(e){
            errorCallback&&errorCallback();
        }
    }
    //当日、昨日、当月、上月
    $(document).on('click','.selectcontain .btn',function () {
        $(this).addClass('select').siblings('button').removeClass('select');
    });

    //侧边栏
    $(document).on('click','.sideClick',function () {
        if (!$(this).hasClass('open')) {
            openMenu();
        } else {
            closeMenu();
        }
    });

    $(document).on('click','.cancel',function () {
        closeMenu();
    });

    $(".date").on('change',function(){
        $('.btn').removeClass('select');
    })
    
    function openMenu() {
        $('.sideClick').addClass('open');
        $('.selectcontain').addClass('open');
    }
    function closeMenu() {
        $('.sideClick').removeClass('open');
        $('.selectcontain').removeClass('open');
    }

    function notLastMon(){
        var year = date.getFullYear();
        var month = date.getMonth()+1;
        today = date.getDate();
        var day = new Date(year,month,0);
        lastDay = day.getDate();//获取某月最后一天
        if(month < 9 ){
            YandM = year + '-' + '0' + month;
        }
        if(month >= 10){
            YandM = year+'-'+month;
        }
    }

    function lastMon(){//需考虑1月的上一月为去年12月
        var year = date.getFullYear();
        var month = date.getMonth();
        if(month==0){
            year = year-1;
            var day = new Date(year,12,0);
            lastDay = day.getDate();
            YandM = year + '-' + '12';
        }else {
            var day = new Date(year,month,0);
            lastDay = day.getDate();//获取某月最后一天
            if(month < 9 ){
                YandM = year + '-' + '0' + month;
            }
            if(month >= 10){
                YandM = year+'-'+month;
            }
        }
    }

     //初始化时间插件
        // $('.form_date_start').datetimepicker({
        //     format:'yyyy-mm-dd',
        //     language:  'zh-CN',
        //     weekStart: 1,
        //     todayBtn:  1,
        //     autoclose: 1,
        //     todayHighlight: 1,
        //     startView: 2,
        //     minView: 2,
        //     forceParse: 0
        // });
        // $('.form_date_end').datetimepicker({
        //     format:'yyyy-mm-dd',
        //     language:  'zh-CN',
        //     weekStart: 1,
        //     todayBtn:  1,
        //     autoclose: 1,
        //     todayHighlight: 1,
        //     startView: 2,
        //     minView: 2,
        //     forceParse: 0
        // });

});

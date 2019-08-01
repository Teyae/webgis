<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="index.aspx.cs" Inherits="WebGIS_enh.index" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
    <title>webgis_enh</title>
    <style type="text/css">
        .RegisterButton
        {
            background-image:
                url(./resource/icons/fam/RegisterButton.png);
        }
    </style>

    <!--引用extjs库-->
    <link rel="stylesheet" type="text/css" 
        href="./lib/ext-4.2.1.883/resources/css/ext-all-neptune.css" />
    <script type="text/javascript" 
        src="./lib/ext-4.2.1.883/bootstrap.js"></script>
    <script type="text/javascript" 
        src="./lib/ext-4.2.1.883/locale/ext-lang-zh_CN.js"></script>

    <%--引用openlayer库--%>
    <script type="text/javascript" 
        src="./lib/OpenLayers-2.13.1/OpenLayers.js"></script>

    <%--引用geoext2库--%>
    <script type="text/javascript" 
        src="./lib/geoext2-2.0.3/loader.js"></script>

    <script type="text/javascript">
        //=========begin:引用=========//
        Ext.require(['*',
                'Ext.Window',
                'Ext.container.Viewport',
                'Ext.layout.container.Border',
                'Ext.tree.plugin.TreeViewDragDrop',
                'Ext.state.Manager',
                'Ext.state.CookieProvider',
                'Ext.window.MessageBox',
                    'Ext.form.*',
                    'Ext.data.*',
                    'Ext.chart.*',
                    'Ext.grid.Panel',
                    'Ext.layout.container.Column',
                    'Ext.grid.column.Action',
                    'Ext.slider.*',
                'GeoExt.tree.Panel',
                'GeoExt.panel.Map',
                'GeoExt.window.Popup',
                'GeoExt.tree.OverlayLayerContainer',
                'GeoExt.tree.BaseLayerContainer',
                'GeoExt.data.LayerTreeModel',
                'GeoExt.tree.View',
                'GeoExt.tree.Column',
                'GeoExt.data.ScaleStore',
                'GeoExt.slider.LayerOpacity',
                'GeoExt.slider.Tip',
                'GeoExt.slider.Zoom',
                'GeoExt.data.MapfishPrintProvider',
                'GeoExt.panel.PrintMap',
                'GeoExt.plugins.PrintExtent',
                'GeoExt.form.field.GeocoderComboBox',
                'GeoExt.Action',
                // 'overridepackage.MaximizeTool',
        ]);
        //=========end:引用=========//

        Ext.onReady(function () {
            Ext.QuickTips.init();
            Ext.state.Manager.setProvider(Ext.create('Ext.state.CookieProvider'));

            //========begin:创建openlayer map对象，设置坐标系统、显示范围、显示级别=========//
            var map = new OpenLayers.Map({});
            var mapOptions = {
                resolutions: [0.703125, 0.3515625, 0.17578125, 0.087890625, 0.0439453125, 0.02197265625, 0.010986328125,
                    0.0054931640625, 0.00274658203125, 0.001373291015625, 6.866455078125E-4, 3.433227539062E-4, 1.716613769531E-4,
                    8.58306884766E-5, 4.29153442383E-5, 2.14576721191E-5, 1.07288360596E-5, 5.3644180298E-6, 2.6822090149E-6,
                    1.3411045074E-6, 6.705522537E-7, 3.352761269E-7],
                projection: new OpenLayers.Projection('EPSG:4326'),     //4326坐标系
                maxExtent: new OpenLayers.Bounds(-180.0, -90.0, 180.0, 90.0),
                numZoomLevels: 15, //控制要显示的级别
                units: "degrees"  //单位为度
            };
            map.setOptions(mapOptions);
            //========end:创建openlayer map对象，设置坐标系统、显示范围、显示级别=========//

            //========begin:创建layer对象，添加到map=========//
           // ===添加OpenStreetMap发布的wms服务
            var LayerOSM = new OpenLayers.Layer.WMS(
                "OpenStreetMap WMS",
                "http://ows.terrestris.de/osm/service?",   //服务url地址，下面讲添加我们自己的服务geosever
                {
                    layers: 'OSM-WMS'     //实际图层,对方提供url，你怎么知道有哪些图层？getmap/get。。。在浏览器中打开会自动下载
                }
            );
            map.addLayers([LayerOSM]);
            var layer_furongqu_region = new OpenLayers.Layer.WMS(
                "layer_furongqu_region",
               "http://localhost:8080/geoserver/teyya/wms?",   //服务url地址，下面讲添加我们自己的服务geosever
               {
                   layers: 'furongqu_region',     //实际图层,对方提供url，你怎么知道有哪些图层？getmap/get。。。在浏览器中打开会自动下载
                   style: '',
                   srs: 'EPSG:4326',
                   format: 'image/png',
                   transparent:true        //注意：必须加这个属性，否则会是白色覆盖
               },
               {
                   isBaseLayer:false,
                   buffer:0,
                   displayOutsideMaxExtent:true         //这些个属性啥意思，在线调可能会很慢，影像数据 
               }
           );
            map.addLayers([layer_furongqu_region]);
            //添加wmts服务，速度会加快
            var layer_etm123456 = new OpenLayers.Layer.WMS(           //name,url,param,options  ////这里wms加瓦片操作有点骚？？
                "geotiff_coverage",
                "http://localhost:8080/geoserver/gwc/service/wms",   //url固定
                {
                    layers: 'teyya:geotiff_coverage',
                    format: 'image/png'
                },
                {
                    isBaseLayer: false,
                    tileSize: new OpenLayers.Size(256, 256)
                }
                );
            map.addLayers([layer_etm123456]);

            //========end:创建layer对象，添加到map=========//

            /************************begin:加载一般的基础控件********************************/
            map.addControl(new OpenLayers.Control.Navigation());  //双击放大,平移
            map.setCenter(new OpenLayers.LonLat(100.254, 35.25), 1);  //添加平移缩放工具条
            map.addControl(new OpenLayers.Control.OverviewMap());  //添加鹰眼图
            map.addControl(new OpenLayers.Control.LayerSwitcher({ 'ascending': false }));  //图层切换工具			
            map.addControl(new OpenLayers.Control.NavToolbar(mapOptions));
            map.addControl(new OpenLayers.Control.ScaleLine());
            //map.zoomToMaxExtent();
            var zb = new OpenLayers.Control.ZoomBox({ out: true });
            var panel = new OpenLayers.Control.Panel({ defaultControl: zb });
            map.addControl(panel);
            /************************end:加载一般的基础控件********************************/


            //========begin:按钮Action========//
            var LayerButtonAction = new OpenLayers.Layer.Vector("LayerButtonAction");
            map.addLayers([LayerButtonAction]);

            var ctrl, toolbarItems = [], action, actions = {};

            // ZoomToMaxExtent control, a "button" control
            action = Ext.create('GeoExt.Action', {
                control: new OpenLayers.Control.
                    ZoomToMaxExtent(),
                map: map,
                text: "max extent",
                tooltip: "zoom to max extent"
            });
            actions["max_extent"] = action;
            toolbarItems.push(Ext.create('Ext.button.Button', action));
            toolbarItems.push("-");

            // Navigation control and DrawFeature controls
            // in the same toggle group
            action = Ext.create('GeoExt.Action', {
                text: "nav",
                control: new OpenLayers.Control.
                    Navigation(),
                map: map,
                // button options
                toggleGroup: "draw",
                allowDepress: false,
                pressed: true,
                tooltip: "navigate",
                // check item options
                group: "draw",
                checked: true
            });
            actions["nav"] = action;
            toolbarItems.push(Ext.create('Ext.button.Button', action));

            action = Ext.create('GeoExt.Action', {
                text: "draw poly",
                control: new OpenLayers.Control.
                    DrawFeature(LayerButtonAction,
                    OpenLayers.Handler.Polygon),
                map: map,
                // button options
                toggleGroup: "draw",
                allowDepress: false,
                tooltip: "draw polygon",
                // check item options
                group: "draw"
            });
            actions["draw_poly"] = action;
            toolbarItems.push(Ext.create('Ext.button.Button', action));

            action = Ext.create('GeoExt.Action', {
                text: "draw line",
                control: new OpenLayers.Control.
                    DrawFeature(LayerButtonAction,
                    OpenLayers.Handler.Path),
                map: map,
                // button options
                toggleGroup: "draw",
                allowDepress: false,
                tooltip: "draw line",
                // check item options
                group: "draw"
            });
            actions["draw_line"] = action;
            toolbarItems.push(Ext.create('Ext.button.Button', action));
            toolbarItems.push("-");

            //	    // SelectFeature control, a "toggle" control
            //	    var ButtonActionSelectCtrl = new OpenLayers.Control.SelectFeature(LayerButtonAction, {
            //	        type: OpenLayers.Control.TYPE_TOGGLE,
            //	        hover: true
            //	    });

            action = Ext.create('GeoExt.Action', {
                text: "select",
                control: new OpenLayers.Control.SelectFeature(LayerButtonAction, {
                    type: OpenLayers.Control.
                        TYPE_TOGGLE,
                    hover: true
                }),
                map: map,
                // button options
                enableToggle: true,
                tooltip: "select feature"
            });
            actions["select"] = action;
            toolbarItems.push(Ext.create('Ext.button.Button', action));
            toolbarItems.push("-");

            // Navigation history - two "button" controls
            ctrl = new OpenLayers.Control.NavigationHistory();
            map.addControl(ctrl);

            action = Ext.create('GeoExt.Action', {
                text: "previous",
                control: ctrl.previous,
                disabled: true,
                tooltip: "previous in history"
            });
            actions["previous"] = action;
            toolbarItems.push(Ext.create('Ext.button.Button', action));

            action = Ext.create('GeoExt.Action', {
                text: "next",
                control: ctrl.next,
                disabled: true,
                tooltip: "next in history"
            });
            actions["next"] = action;
            toolbarItems.push(Ext.create('Ext.button.Button', action));
            toolbarItems.push("->");

            // Reuse the GeoExt.Action objects created above
            // as menu items
            toolbarItems.push({
                text: "menu",
                menu: Ext.create('Ext.menu.Menu', {
                    items: [
                    // ZoomToMaxExtent
                        Ext.create('Ext.button.Button', actions["max_extent"]),
                    // Nav
                        Ext.create('Ext.menu.CheckItem', actions["nav"]),
                    // Draw poly
                        Ext.create('Ext.menu.CheckItem', actions["draw_poly"]),
                    // Draw line
                        Ext.create('Ext.menu.CheckItem', actions["draw_line"]),
                    // Select control
                        Ext.create('Ext.menu.CheckItem', actions["select"]),
                    // Navigation history control
                        Ext.create('Ext.button.Button', actions["previous"]),
                        Ext.create('Ext.button.Button', actions["next"])
                    ]
                })
            });
            //========end:按钮Action========//

            //========begin:查询地名并定位到地图========//
            var pointData;
            var pointsStore = new Ext.data.Store({
                fields: [{ name: 'poiName' },
                { name: 'lon' },
                { name: 'lat' },
                { name: 'description' }]
            });

            function findLocation() {
                var LocationText = Ext.getCmp
                ("LocationText").getValue(); //地名

                if (Ext.util.Format.
                    trim(LocationText) == "") {
                    Ext.Msg.alert("提示",
                        "地名不能为空");
                    return;
                }

                Ext.Ajax.request({
                    url: "location.ashx?LocationText=" + LocationText,
                    method: "get",
                    success: function (response) {
                        var getData = response.responseText; //获取服务器数据
                        console.log(getData);
                        if (getData != "") {
                            pointData = eval(getData); //将json字符串转换为array
                            console.log(pointData);
                            pointsStore.removeAll();
                            pointsStore.loadData(pointData);
                            console.log(pointsStore);
                        } else {
                            Ext.Msg.alert("警告", "查询失败！");
                        }
                    },
                    failure: function (response, options) {
                        Ext.Msg.alert("失败");
                    }
                });
            }

            var marker_layer = new OpenLayers
            .Layer.Markers("markers");
            var marker_size = new OpenLayers.
                Size(32, 32);
            var marker_offset = new OpenLayers
            .Pixel(-(marker_size.w / 2),
            -(marker_size.h));
            var marker_starticon = new OpenLayers
            .Icon("./resources/images/address.png",
            marker_size, marker_offset);
            map.addLayers([marker_layer]);
            //========end:查询地名并定位到地图========//



            //========begin:轨迹回放========//
            //将所有点坐标放入数组
            var allpoints = [120.1429508459857, 30.26970728785357,120.1433203727838, 30.26987813036302,
            120.1435960763801, 30.27004810202611,120.1440598871008, 30.27030170181578,120.1444335085162, 30.270470517764,
            120.144810643117, 30.27055560506131,120.1451765255314, 30.27073067247369,120.1456327853926, 30.27099172208011,
            120.146004257442, 30.27116346602122,120.1462800039004, 30.27133552745275,120.1467445443051, 30.27151014804406,
            120.1471173252899, 30.27168188169949,120.1473998801327, 30.27176758744826,120.1477675134656, 30.27202590069018,
            120.1482317030441, 30.27228427614901,120.1486055668594, 30.2724565330538,120.1489743480442, 30.27271556471561,
            120.1492577998196, 30.27280160960896,120.1497279906527, 30.27297467574628,120.1501076140693, 30.2730609856902,
            120.15022542109, 30.27271277764034,120.1503419628279, 30.27236616902568,120.150370961101, 30.2719304613715,
            120.1503926298281, 30.2715024323573,120.1505031297421, 30.27116282807489,120.1505171704705, 30.27090563537451,
            120.1505403491641, 30.27047775120843,120.150561916451, 30.27005198112197,120.1506784270925, 30.26962727257277,
            120.1507930652985, 30.26928582475572,120.1510103543296, 30.26885733698972,120.1511227741985, 30.26851854995961,
            120.1513340941565,30.26809595127256];     //实际应用中，这个数组写到数据库，软件和硬件实现松耦合，这个注释牛了，谢老师实时连接查询数据库，得到当前最新点；如果是多个，那么就是地图不动，现在是目标不动，


            //获得一定数据量就可以做数据挖掘了，老美你好吗，反恐，监听，只要在有网，你就完了，绝命毒师那会儿，环境犯罪学，route ，轨迹有规律，我可以进警局了帮警局做系统，嗯很有兴趣，消费、行为、人类关系，破案，规律，社交关系的挖掘。我想学数据挖掘，期末：给一个框架，加功能，
            //next ：实现图片切换，动态效果，动态→重新加载，已有32张png图片，首先，图片只有宽和高的像素坐标，要确定图片位置是个问题，

            var vectorLayer, car, lineFeature;
            var px, py;
            var x = 0;
            var car_size = new OpenLayers.Size(32, 32);
            //ar zoom = map.getZoom();
            var zoom = 15;

            function startReplay() {
                //feature style
                var style_green = {
                    strokeColor: "#339933",
                    strokeOpacity: 1,
                    strokeWidth: 3,
                    pointRadius: 6,
                    pointerEvents: "visiblePainted"
                };

                x = 0;
                if (vectorLayer != null) {
                    map.removeLayer(vectorLayer);
                }
                if (car != null) {
                    map.removeLayer(car);
                }

                //	        px = Math.random() * (122 - 121 + 0.001) + 121;
                //	        py = Math.random() * (30 - 29 + 0.001) + 29;
                //	        var lonlat = new OpenLayers.LonLat(px, py);
                var lonlat = new OpenLayers.LonLat(allpoints[0], allpoints[1]);
                map.setCenter(lonlat, zoom);

                vectorLayer = new OpenLayers.Layer.Vector("route");
                map.addLayer(vectorLayer);

                car = new OpenLayers.Layer.Markers("car");
                map.addLayer(car);

                var imgUrl = "./resources/images/car.png";
                var icon = new OpenLayers.Icon(imgUrl, car_size);
                var marker = new OpenLayers.Marker(lonlat, icon);
                car.addMarker(marker);

                lineFeature = new OpenLayers.Feature.Vector(
                    new OpenLayers.Geometry.LineString(lonlat.lon, lonlat.lat), 
                    null, style_green);
                vectorLayer.addFeatures([lineFeature]);

                fn();
            }

            function fn() {
                if (x < allpoints.length) {
                    //	            px = Math.random() * (122 - 121 + 0.001) + 121;
                    //	            py = Math.random() * (30 - 29 + 0.001) + 29;
                    var lonlat = new OpenLayers.LonLat(allpoints[x], 
                    allpoints[x + 1]);
                    map.setCenter(lonlat, zoom);

                    var newPoint = new OpenLayers.Geometry.Point(lonlat.lon, 
                    lonlat.lat);
                    lineFeature.geometry.addPoint(newPoint);
                    vectorLayer.drawFeature(lineFeature);

                    car.clearMarkers();
                    var imgUrl = "./resources/images/car.png";
                    var icon = new OpenLayers.Icon(imgUrl, car_size);
                    var marker = new OpenLayers.Marker(lonlat, icon);
                    car.addMarker(marker);
                    //x++;
                    x += 2;
                    setTimeout(fn, 1000);

                    console.log(x);
                }
            }
            //========end:轨迹回放========//

            //========begin:动画显示多张图片========//
            var img_extent = new OpenLayers.
                Bounds(-131.0888671875, 30.5419921875,
            -78.3544921875, 53.7451171875);
            var img_size = new OpenLayers.Size(780, 480);
            var img_url = image = null;
            var imgArray = [];
            for (var i = 1; i <= 32; i++) {
                index = (i < 10) ? "0" + i : i;

                //img_url = "./App_Data/radar/nexrad" + index + ".png";//此种路径无法访问？
                img_url = "nexrad" + index + ".png";
                //img_url = "http://localhost/radar/nexrad" + index + ".png";
                image = new OpenLayers.Layer.
                    Image(img_url, img_url, img_extent,
                img_size,
                {
                    isBaseLayer: false,
                    alwaysInRange: true, // Necessary to always draw the image
                    visibility: false
                });
                imgArray.push(image);
                map.addLayer(image);
            }
            imgArray[0].setVisibility(true);

            var currentIndex = 0;
            function animation(value) {
                imgArray[currentIndex].setVisibility(false);
                currentIndex = Math.floor(value * 31 / 100);
                imgArray[currentIndex].setVisibility(true);
            }

            var interval = null;
            function animateAction(checked) {
                if (checked) {
                    interval = setInterval(function () {
                        var v = Ext.getCmp("animSlider").getValue();
                        v = (v >= 100) ? 0 : (v + 1);
                        Ext.getCmp("animSlider").setValue(v);
                        animation(v);
                    },
                    50); //控制刷新间隔，单位毫秒
                }
                else {
                    clearInterval(interval);
                }
            }
            //========end:动画显示多张图片========//



            //===============begin:图表===============//
            //use a renderer for values in the data view.
            function perc(v) {
                return v + '%';
            }

            var form = false,
            selectedRec = false,
            // Loads fresh records into the radar store based upon the passed company record
            updateRadarChart = function (rec) {
                radarStore.loadData([{
                    'Name': 'Price',
                    'Data': rec.get('price')
                }, {
                    'Name': 'Revenue %',
                    'Data': rec.get('revenue %')
                }, {
                    'Name': 'Growth %',
                    'Data': rec.get('growth %')
                }, {
                    'Name': 'Product %',
                    'Data': rec.get('product %')
                }, {
                    'Name': 'Market %',
                    'Data': rec.get('market %')
                }]);
            };

            // sample static data for the store
            var myData = [
                ['3m Co'],
                ['Alcoa Inc'],
                ['Altria Group Inc'],
                ['American Express Company'],
                ['American International Group, Inc.'],
                ['AT&T Inc'],
                ['Boeing Co.'],
                ['Caterpillar Inc.'],
                ['Citigroup, Inc.'],
                ['E.I. du Pont de Nemours and Company'],
                ['Exxon Mobil Corp'],
                ['General Electric Company'],
                ['General Motors Corporation'],
                ['Hewlett-Packard Co'],
                ['Honeywell Intl Inc'],
                ['Intel Corporation'],
                ['International Business Machines'],
                ['Johnson & Johnson'],
                ['JP Morgan & Chase & Co'],
                ['McDonald\'s Corporation'],
                ['Merck & Co., Inc.'],
                ['Microsoft Corporation'],
            ];

            for (var i = 0, l = myData.length, rand = Math.random; i < l; i++) {
                var data = myData[i];
                data[1] = ((rand() * 10000) >> 0) / 100;
                data[2] = ((rand() * 10000) >> 0) / 100;
                data[3] = ((rand() * 10000) >> 0) / 100;
                data[4] = ((rand() * 10000) >> 0) / 100;
                data[5] = ((rand() * 10000) >> 0) / 100;
            }

            //create data store to be shared among the grid and bar series.
            var ds = Ext.create('Ext.data.ArrayStore', {
                fields: [
                { name: 'company' },
                { name: 'price', type: 'float' },
                { name: 'revenue %', type: 'float' },
                { name: 'growth %', type: 'float' },
                { name: 'product %', type: 'float' },
                { name: 'market %', type: 'float' }
                ],
                data: myData,
                listeners: {
                    beforesort: function () {
                        //	                if (barChart) {
                        //	                    var a = barChart.animate;
                        //	                    barChart.animate = false;
                        //	                    barChart.series.get(0).unHighlightItem();
                        //	                    barChart.animate = a;
                        //	                }
                    },
                    //add listener to (re)select bar item after sorting or refreshing the dataset.
                    refresh: {
                        fn: function () {
                            if (selectedRec) {
                                //	                        highlightCompanyPriceBar(selectedRec);
                            }
                        },
                        // Jump over the chart's refresh listener
                        delay: 1
                    }
                }
            });

            //create radar store.
            var radarStore = Ext.create('Ext.data.JsonStore', {
                fields: ['Name', 'Data'],
                data: [
            {
                'Name': 'Price',
                'Data': 100
            }, {
                'Name': 'Revenue %',
                'Data': 100
            }, {
                'Name': 'Growth %',
                'Data': 100
            }, {
                'Name': 'Product %',
                'Data': 100
            }, {
                'Name': 'Market %',
                'Data': 100
            }]
            });

            var radarChart, gridPanel, chartPanel;
            var chartWindow;
            function initChart() {

                //Radar chart will render information for a selected company in the
                //list. Selection can also be done via clicking on the bars in the series.
                radarChart = Ext.create('Ext.chart.Chart', {
                    margin: '0 0 0 0',
                    insetPadding: 20,
                    flex: 1.2,
                    animate: true,
                    store: radarStore,
                    theme: 'Blue',
                    axes: [{
                        steps: 5,
                        type: 'Radial',
                        position: 'radial',
                        maximum: 100
                    }],
                    series: [{
                        type: 'radar',
                        xField: 'Name',
                        yField: 'Data',
                        showInLegend: false,
                        showMarkers: true,
                        markerConfig: {
                            radius: 4,
                            size: 4,
                            fill: 'rgb(69,109,159)'
                        },
                        style: {
                            fill: 'rgb(194,214,240)',
                            opacity: 0.5,
                            'stroke-width': 0.5
                        }
                    }]
                });

                //create a grid that will list the dataset items.
                gridPanel = Ext.create('Ext.grid.Panel', {
                    id: 'company-form',
                    flex: 7,
                    store: ds,
                    //	        title: 'Company Data',
                    columns: [
                {
                    id: 'company',
                    text: 'Company',
                    flex: 1,
                    sortable: true,
                    dataIndex: 'company'
                },
                {
                    text: 'Price',
                    width: 90,
                    sortable: true,
                    dataIndex: 'price',
                    align: 'right',
                    renderer: 'usMoney'
                },
                {
                    text: 'Revenue',
                    width: 110,
                    sortable: true,
                    align: 'right',
                    dataIndex: 'revenue %',
                    renderer: perc
                },
                {
                    text: 'Growth',
                    width: 100,
                    sortable: true,
                    align: 'right',
                    dataIndex: 'growth %',
                    renderer: perc
                },
                {
                    text: 'Product',
                    width: 110,
                    sortable: true,
                    align: 'right',
                    dataIndex: 'product %',
                    renderer: perc
                },
                {
                    text: 'Market',
                    width: 100,
                    sortable: true,
                    align: 'right',
                    dataIndex: 'market %',
                    renderer: perc
                }
                    ],

                    listeners: {
                        selectionchange: function (model, records) {
                            var fields;
                            if (records[0]) {
                                selectedRec = records[0];
                                if (!form) {
                                    form = this.up('panel').down('form').getForm();
                                    fields = form.getFields();
                                    fields.each(function (field) {
                                        if (field.name != 'company') {
                                            field.setDisabled(false);
                                        }
                                    });
                                } else {
                                    fields = form.getFields();
                                }

                                // prevent change events from firing
                                form.suspendEvents();
                                form.loadRecord(selectedRec);
                                form.resumeEvents();
                            }
                        }
                    }
                });

                /*
                * Here is where we create the main Panel
                */
                chartPanel = Ext.create('Ext.panel.Panel', {
                    //	        title: 'Company data',
                    //	        frame: true,
                    id: 'chartPanel',
                    bodyPadding: 5,
                    width: 1050,
                    height: 740,
                    fieldDefaults: {
                        labelAlign: 'left',
                        msgTarget: 'side'
                    },
                    layout: {
                        type: 'vbox',
                        align: 'stretch'
                    },
                    items: [
                {
                    xtype: 'container',
                    layout: { type: 'hbox', align: 'stretch' },
                    flex: 3,
                    items: [gridPanel, {
                        xtype: 'form',
                        flex: 3,
                        layout: {
                            type: 'vbox',
                            align: 'stretch'
                        },
                        margin: '0 0 0 5',
                        //                    title: 'Company Details',
                        items: [{
                            margin: '5',
                            xtype: 'fieldset',
                            flex: 1,
                            title: 'Company details',
                            defaults: {
                                width: 240,
                                labelWidth: 90,
                                disabled: true,
                                // min/max will be ignored by the text field
                                maxValue: 100,
                                minValue: 0,
                                enforceMaxLength: true,
                                maxLength: 5,
                                bubbleEvents: ['change']
                            },
                            defaultType: 'numberfield',
                            items: [{
                                fieldLabel: 'Name',
                                name: 'company',
                                xtype: 'textfield',
                                enforceMaxLength: false
                            }, {
                                fieldLabel: 'Price',
                                name: 'price'
                            }, {
                                fieldLabel: 'Revenue %',
                                name: 'revenue %'
                            }, {
                                fieldLabel: 'Growth %',
                                name: 'growth %'
                            }, {
                                fieldLabel: 'Product %',
                                name: 'product %'
                            }, {
                                fieldLabel: 'Market %',
                                name: 'market %'
                            }]
                        }, radarChart],
                        listeners: {
                            // buffer so we don't refire while the user is still typing
                            buffer: 200,
                            change: function (field, newValue, oldValue, listener) {
                                if (selectedRec && form) {
                                    if (newValue > field.maxValue) {
                                        field.setValue(field.maxValue);
                                    } else {
                                        if (form.isValid()) {
                                            form.updateRecord(selectedRec);
                                            updateRadarChart(selectedRec);
                                        }
                                    }
                                }
                            }
                        }
                    }]
                }]
                });
            }
            //===============end:图表===============//


            //===============begin:popup窗体===============//	      先有图层，在有要素，再绑定，再弹框，弹框要素的属性设置 
            var popup;
            // create a vector layer, add a feature into it
            var LayerPopup = new OpenLayers.Layer.Vector("LayerPopup");
            LayerPopup.addFeatures(new OpenLayers.Feature.Vector(new OpenLayers.Geometry.Point(120, 30)));
            // create select feature control
            var selectCtrl = new OpenLayers.Control.SelectFeature(LayerPopup);
            // define "createPopup" function
            var bogusMarkup = "弹出框测试^_^!";

            function createPopup(feature) {
                var constrainOpts = "constrain-full"; //no-constrain,constrain-header,constrain-full
                var popupOpts = Ext.apply({
                    title: 'My Popup',
                    location: feature,
                    width: 200,
                    height: 200,
                    //	            html: bogusMarkup,
                    maximizable: true,
                    collapsible: true,
                    anchorPosition: 'auto',
                    alwaysOnTop: true,
                    items: [
                            {
                                labelWidth: 30,
                                width: 150,
                                anchor: '100%',
                                //labelAlign: 'right',
                                xtype: 'textfield',
                                fieldLabel: '地名',
                                emptyText: '杭州大厦'
                            }, 
                            {
                                xtype: 'button',
                                text: '查询',
                                tooltip: '查询按钮'
                            }]
                }, constrainOpts);

                popup = Ext.create('GeoExt.window.Popup', popupOpts);
                // unselect feature when the popup is closed
                popup.on({
                    close: function () {
                        if (OpenLayers.Util.indexOf(LayerPopup.selectedFeatures,
                                               this.feature) > -1) {
                            selectCtrl.unselect(this.feature);
                        }
                    }
                });
                popup.show();
            }

            // create popup on "featureselected"
            LayerPopup.events.on({
                featureselected: function (e) {
                    createPopup(e.feature);
                }
            });
            map.addLayers([LayerPopup]);
            map.addControl(selectCtrl);        //control 激活
            selectCtrl.activate();
            //===============end:popup窗体===============//

            //===============begin:图层列表数据===============// 很多时候mvc m和v通常绑定，由c控制刷新，架构方式
            var store = Ext.create('Ext.data.TreeStore', {
                model: 'GeoExt.data.LayerTreeModel',
                root: {
                    expanded: true,
                    children: [
                        {
                            plugins: ['gx_baselayercontainer'],
                            expanded: true,
                            text: "基础图层"
                        },
                        {
                            plugins: ['gx_overlaylayercontainer'],
                            expanded: true,
                            text: "叠加图层"
                        }
                    ]
                }
            });


            //===============end:图层列表数据===============//





            //========begin: UI界面=========//    north center以及east
            var mapPanel;
            var viewport = Ext.create('Ext.Viewport', {
                id: 'border-example',
                layout: 'border', //border
                items: [
                    mapPanel = Ext.create('GeoExt.panel.Map', {
                        region: 'center',
                        title: '地图',
                        map: map,
                        center: '120,30',
                        zoom: 5,
                        stateful: true,
                        stateId: 'mappanel',
                        dockedItems: [
                        {
                            xtype: 'toolbar',
                            dock: 'top',
                            items: [
                            {
                                text: '当前地图中心',
                                handler: function () {
                                    var c = GeoExt.panel.Map.guess().map.getCenter();
                                    Ext.Msg.alert(this.getText(), c.toString());
                                }
                            },
                            {
                                text: '全图',
                                handler: function () {
                                    map.zoomToMaxExtent();
                                }
                            },
                            {
                                text: '定位到杭州',
                                handler: function () {
                                    var lonlat = new OpenLayers.LonLat(120.16, 30.29);
                                    map.zoomTo(10);
                                    map.panTo(lonlat);
                                }
                            },
                            {
                                text: '动态轨迹',
                                handler: function () {
                                    startReplay();
                                }
                            },
                                                        Ext.create('Ext.slider.Single', {
                                                            //renderTo: 'custom-slider',  //注意：渲染到dockitem toolbar上，custom-slider样式设置无效
                                                            hideLabel: true,
                                                            width: 100,
                                                            increment: 1, //此处必须为1，否则slider滑条不动？
                                                            minValue: 0,
                                                            maxValue: 100,
                                                            id: 'animSlider'
                                                        }),
                            {
                                text: '播放',
                                enableToggle: true,
                                listeners: {
                                    toggle: function (sender, checked) {
                                        if (checked == true) {
                                            map.setCenter(new OpenLayers
                                                .LonLat(-80, 40), 2);
                                            animateAction(true);
                                        }
                                        else {
                                            animateAction(false);
                                        }
                                    }
                                }
                            },
                            {
                                text: '图表',
                                handler: function () {
                                    if (Ext.getCmp("chartPanel") == null) {
                                        initChart();
                                        chartWindow = Ext.create('Ext.Window', {
                                            title: "Chart",
                                            layout: "fit",
                                            border: true,
                                            constrain: true, //将窗体约束到可见区域
                                            maximizable: true,
                                            width: 800,
                                            height: 400,
                                            items: [chartPanel]
                                        });
                                        chartWindow.show();
                                    }
                                }
                            },
                            "->", //右对齐
                            {
                                text: '退出',
                                handler: function () {
                                    window.navigate("login.aspx");
                                }
                            }]
                        }]
                    }),
                    {
                        xtype: 'panel',
                        region: 'north',
                        height: 70,
                        margins: '0 0 5 0',
                        dockedItems: [
                            {
                                height: 70,
                                xtype: 'toolbar',
                                style: {
                                    background:
                                        'url(./resources/images/banner.jpg)  left'
                                },
                                items: [
                                    '->',
                                    {
                                        xtype: 'button',
                                        text: 'BaiduAPI',
                                        scale: 'medium',
                                        iconAlign: 'top',
                                        iconCls: 'RegisterButton',
                                        handler: function () {
                                            window.location.href = "/indexBaidu.aspx";
                                        }
                                    }
                                ]
                            }
                        ]
                    },
                    //查询定位：前端设计:新加面板，实现查询定位east，属性→图，以查出来结果为中心，输入/确定/查询模式选择/查询结果list（加上单机/双击触发事件）/在地图上加上图标
                    {
                        xtype: 'tabpanel',
                        region: 'east',
                        title: '查询',
                        dockedItems: [{          //固定的，放toolbar
                            dock: 'top',
                            xtype: 'toolbar',
                            items: [
                                {
                                    labelWidth: 30,
                                    width: 150,
                                    anchor: '100%',
                                    //labelAlign: 'right',
                                    xtype: 'textfield',
                                    fieldLabel: '地名',
                                    emptyText: '杭州大厦',
                                    id: 'LocationText'
                                }, "->",
                                {
                                    xtype: 'button',
                                    text: '查询',
                                    tooltip: '查询按钮',
                                    handler: function () {
                                        findLocation(); //查询结果更新pointsStore
                                    }
                                }]
                        }],
                        animCollapse: true,
                        collapsible: true,
                        split: true,
                        width: 225, // give east and west regions a width
                        minSize: 175,
                        maxSize: 400,
                        margins: '0 5 0 0',
                        activeTab: 0,
                        tabPosition: 'bottom',
                        items: [
                        Ext.create('Ext.grid.Panel', {
                            title: '查询结果',
                            id: 'pointlist',
                            store: pointsStore,      //绑定数据源
                            columns: [                //放了三列
                                {
                                    width: 40, resizable: false, hideable: false, sortable: false, menuDisabled: true,
                                    renderer: function (value, metaData, record, rowIndex, colIndex, store) {
                                        return '<image style="width:16px;height:16px;" src="./resources/images/address.png" />';   //放了一个图标
                                    }
                                },
                                {
                                    text: '地名', menuDisabled: true, dataIndex: 'poiName', flex: 1
                                },
                                {
                                    xtype: 'actioncolumn',    //响应用的，点击跳转，可获取行列号，作为参数传入函数定位
                                    menuDisabled: true,
                                    text: '定位',
                                    width: 50,
                                    items: [{
                                        icon: './resources/images/location.png',
                                        tooltip: '地图定位',
                                        handler: function (grid, rowIndex, colIndex) {
                                            marker_layer.clearMarkers();
                                            var x = grid.store.getAt(rowIndex).raw["lon"];
                                            var y = grid.store.getAt(rowIndex).raw["lat"];
                                            var lonlat = new OpenLayers.LonLat(x, y);
                                            var marker = new OpenLayers.Marker(lonlat,
                                                marker_starticon);
                                            marker_layer.addMarker(marker);
                                            map.zoomTo(13);
                                            map.panTo(lonlat);
                                        }
                                    }]
                                }
                            ]
                        }),
                        Ext.create('Ext.grid.PropertyGrid', {
                            title: 'Property Grid',
                            closable: true,
                            source: {
                                "(name)": "Properties Grid",
                                "grouping": false,
                                "autoFitColumns": true,
                                "productionQuality": false,
                                "created": Ext.Date.parse('10/15/2006', 'm/d/Y'),
                                "tested": false,
                                "version": 0.01,
                                "borderWidth": 1
                            }
                        })]
                    },
                    //west面板 加图层信息 树状图绑定图层信息，折叠面板可加其他东西 store
                    //写完west后，实现功能：实现运动目标随轨迹，监测目标运动状态，？？？就是动画吧。。。有了轨迹和目标，如何让目标沿轨迹运动，间隔刷新的触发事件（）function ontime事件
                    //首先有一条线，用random得到间隔点，加上画线段的函数，settimeout ,定时器判定结束，新画一条线就加一次车，不停的触发函数，画车子
                    {
                        region: 'west',
                        stateId: 'navigation-panel',
                        id: 'west-panel', // see Ext.getCmp() below
                        title: '工具',
                        split: true,
                        width: 200,
                        minWidth: 175,
                        maxWidth: 400,
                        collapsible: true,
                        animCollapse: true,
                        margins: '0 0 0 5',
                        layout: 'accordion',
                        items: [ Ext.create('GeoExt.tree.Panel',{
                                    border:true,
                                    title:"图层列表",
                                    iconCls:'layerlist',
                                    width:250,
                                    split:true,
                                    collapaible:true,
                                    store:store,
                                    rootVisible:false,
                                    lines:false
                        }),
                        {
                            contentE1: 'west',
                            title: 'Navigation',
                            iconCls:'nav'
                        },
                        {
                            title: 'Settings',
                            html: '<p>Some settings in here.</p>',
                            iconCls: 'nav'
                        },
                        {
                            title:'information',
                            html: '<p>Some info in here.</p>',
                            iconCls: 'info'
                        }
                        ]
                    }
                        

                ]

            });
            //========end: UI界面=========//
        });
    </script>
</head>
<body>
    
</body>
</html>

<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="login.aspx.cs" Inherits="WebGIS_enh.login" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
    <title></title>
    <link rel="stylesheet" type="text/css" href="~/lib/ext-4.2.1.883/resources/css/ext-all-neptune.css"/>
    <script type="text/javascript" src="./lib/ext-4.2.1.883/bootstrap.js"></script>                   
    <script type="text/javascript" src="./lib/ext-4.2.1.883/locale/ext-lang-zh_CN.js"></script>  
    

    <style type ="text/css">
        #div1
        {
            position:absolute;
            width: 400px;
            height:320px;
            left:50%;
            top:50%;
            margin-left:-200px;
            margin-top:-200px;
        }
        #div2
        {
            position:fixed;
            width:1366px;
            height:768px;
            background-image:url(./resources/images/background2.png);           
        }
    </style>
    <script type ="text/javascript">
        Ext.require(['*']);
        var registerForm = null;          //控制显示和隐藏的功能
            Ext.onReady(function () {
                Ext.QuickTips.init();
                Ext.state.Manager.setProvider(Ext.create('Ext.state.CookieProvider'));
                //UI界面
                //下面写函数
                function register() {
                    var r_username = Ext.getCmp("r_username").getValue();
                    var r_password = Ext.getCmp("r_password").getValue();
                    var r_password2 = Ext.getCmp("r_password2").getValue();
                    var r_name = Ext.getCmp("r_name").getValue();
                    var r_company = Ext.getCmp("r_company").getValue();
                    var r_email = Ext.getCmp("r_email").getValue();
                    var r_birthday = Ext.getCmp("r_birthday").getValue();

                    if (Ext.util.Format.trim(r_username) == "" || Ext.util.Format.trim(r_password) == "" || Ext.util.Format.trim(r_password2) == "")
                    {
                        Ext.Msg.alert("提示", "用户名或密码不能为空");
                        return;
                    }
                    if (r_password != r_password2)
                    {
                        Ext.Msg.alert("提示", "两次密码输入不匹配");
                        return;
                    }

                    //核心来了，阿贾克斯的异步请求
                    Ext.Ajax.request({
                        url: "userregister.ashx?r_username=" + r_username
                            + "&r_password=" + r_password
                            + "&r_name=" + r_name
                            + "&r_company=" + r_company
                            + "&r_email=" + r_email
                            + "&r_birthday=" + r_birthday,
                        method: "get",
                        success: function (response) {
                            var getData = response.responseText;
                            if (getData == "ok") {
                                Ext.Msg.alert("提示", "注册成功！");
                            } else {
                                Ext.Msg.alert("警告", "注册失败！");
                            }
                            registerForm.close();
                            registerForm = null;
                        },
                        failure: function (response, options) {
                            Ext.Msg.alert("请求失败");
                            registerForm.close();
                            registerForm = null;
                        }
                    }
                    );
                }
                function CheckLogin() {
                    var userName = Ext.getCmp("username").getValue(); //用户名
                    var userPass = Ext.getCmp("password").getValue(); //密 码 

                    if (Ext.util.Format.trim(userName) == "" || Ext.util.Format.trim(userPass) == "") {//用户名和密码不能为空   
                        Ext.Msg.alert("提示", "用户名或密码不能为空");
                        return;
                    }

                    Ext.Ajax.request({
                        url: "CheckLogin.ashx?username=" + userName + "&password=" + userPass, //将用户名和密码传送到后台验证url   
                        method: "get",
                        success: function (response) {
                            var getData = response.responseText; //获取服务器数据                         
                            if (getData == "ok") {
                                window.location.href =
                                "/index.aspx?username=" + userName; //登录成功了    
                            } else {
                                Ext.Msg.alert("警告", "登录失败！");
                            }
                        },
                       // failure: function (response, options) {
                        //    Ext.Msg.alert("失败");
                     //   }
                    });
                }


                var form = Ext.create("Ext.form.Panel", {
                    id: 'loginForm',
                    renderTo: Ext.get('div1'),
                    width: 320,
                    frame: true,
                    bodyPadding: 10,
                    title: "bhsmzgvrnkuealros(@Copyright Teya)",
                    autoScroll: true,    //自动创建滚动条
                    defaultType: 'textfield',
                    defaults: {
                        anchor: '100%'
                    },
                    items: [
                        {
                            allowBlank: false,
                            fieldLabel: '用户名',
                            id: 'username',            //资源标识符
                            name: 'LoginName',
                            emptyText: 'user id'
                        },
                        {
                            allowBlank: false,
                            fieldLabel: '密码',
                            id: 'password',
                            name: 'LoginPsd',
                            emptyText: 'password',
                            inputType: 'password'
                        },
                        {
                            xtype: 'checkbox',        //item换类型用xtype
                            fieldLabel: '记住我',
                            name: 'remember'
                        },
                    ],
                    buttons: [{
                        text: '注册',
                        handler: function () {
                            if (registerForm == null) {
                                registerForm = Ext.create("Ext.window.Window", {
                                    defaultType: 'textfield',
                                    frame: true,
                                    title: '注册',
                                    bodyPadding: 10,
                                    autoScroll: true,
                                    width: 355,
                                    closable: false,
                                    items: [{
                                        xtype: 'fieldset',
                                        title: '用户信息',
                                        defaultType: 'textfield',
                                        defaults: {
                                            anchor: '100%',
                                        },
                                        fieldDefaults: {
                                            labelAlign: 'right',
                                            labelWidth: 115,
                                            msgTarget: 'side'
                                        },
                                        items: [{
                                            allowBlank: false,
                                            fieldLabel: '用户名',
                                            name: 'user',
                                            emptyText: 'user id',
                                            id: 'r_username',
                                        },
                                        {
                                            allowBlank: false,
                                            fieldLabel: '密码',
                                            name: 'pass',
                                            emptyText: 'password',
                                            inputType: 'password',
                                            id: 'r_password'
                                        },
                                        {
                                            allowBlank: false,
                                            fieldLabel: '再次输入密码',
                                            name: 'pass',
                                            emptyText: 'password',
                                            inputType: 'password',
                                            id: 'r_password2'
                                        }
                                        ]
                                    },
                                    {
                                        xtype: 'fieldset',
                                        title: '联系信息',
                                        defaultType: 'textfield',
                                        defaults: {
                                            anchor: '100%'
                                        },
                                        fieldDefaults: {
                                            labelAligh: 'right',
                                            labelWidth: 115,
                                            msgTarget: 'side'
                                        },
                                        items: [{
                                            fieldLabel: '姓名',
                                            emptyText: '张三',
                                            name: 'UserName',
                                            id: 'r_name'
                                        },
                                        {
                                            fieldLabel: '公司',
                                            name: 'company',
                                            id: 'r_company'
                                        },
                                        {
                                            fieldLabel: 'Email',
                                            name: 'email',
                                            vtype: 'email',
                                            id: 'r_email'
                                        },
                                        {
                                            xtype: 'datefield',
                                            fieldLabel: '生日',
                                            name: 'bob',
                                            allowBlank: false,
                                            maxValue: new Date(),
                                            id: 'r_birthday'
                                        }
                                        ]
                                    }
                                    ],
                                    buttons: [
                                        {
                                            text: '确定',
                                            handler: function () {
                                                register();
                                            }
                                        },
                                        {
                                            text: '取消',
                                            handler: function () {
                                                registerForm.close();
                                                registerForm = null;
                                            }
                                        }
                                    ]
                                }

                                    ).show();
                            }
                        }
                    },
                    {
                        text: '登录',
                        handler: function () {
                            CheckLogin();
                        }
                    }
                    ]

                } );
            });
    </script>

</head>
<body>
    <div id="div2">
        <div id="div1" align="center">
        </div>
    </div>
</body>
</html>

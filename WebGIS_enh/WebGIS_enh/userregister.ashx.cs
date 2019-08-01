using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;             //web命名空间

using System.Data;
using System.Data.OleDb;           //数据库操作API接口
using System.Web.Configuration;     //读取数据库配置，config字段
using System.Web.SessionState;       


namespace WebGIS_enh
{
    /// <summary>
    /// userregister 的摘要说明
    /// </summary>
    public class userregister : IHttpHandler           //继承，实现http的接口，桌面应用继承的是system.window
    {
        public static readonly string connStr = WebConfigurationManager.ConnectionStrings["AccessConnectionString"].ConnectionString + HttpContext.Current.Server.MapPath(WebConfigurationManager.ConnectionStrings["Access_Path"].ConnectionString);//配置连接
        public void ProcessRequest(HttpContext context)        //处理一个前端发的请求 //HttpContext
        {   
            context.Response.ContentType = "text/plain";                 

            string r_username = context.Request.QueryString["r_username"];
            string r_password = context.Request.QueryString["r_password"];
            string r_email = context.Request.QueryString["r_email"];
            string r_company = context.Request.QueryString["r_company"];
            string r_birthday = context.Request.QueryString["r_birthday"];
            string r_name = context.Request.QueryString["r_name"];

            OleDbConnection conn = new OleDbConnection(connStr);
            try
            {
                conn.Open();
                string sql = "insert into users([username],[password],[pname],[company],[email],[birthday])values('" + r_username + "','" + r_password + "','" + r_name + "','" + r_birthday + "','" + r_email + "','" + r_company + "',)";
                OleDbCommand cmd = new OleDbCommand(sql, conn);
                cmd.ExecuteNonQuery();

                conn.Close();
                context.Response.Write("ok");

            }

            catch 
            {
                context.Response.Write("fail");
            }

            context.Response.End();                     //返回
        }

        public bool IsReusable
        {
            get
            {
                return false;
            }
        }
    }
}
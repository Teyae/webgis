using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

using System.Web.SessionState;
using System.Web.Configuration;

using System.Data;
using System.Data.OleDb;

namespace WebGIS_enh
{
    /// <summary>
    /// Summary description for CheckLogin
    /// </summary>
    //注意，此处必须实现IRequiresSessionState接口，否则context.Session会报null空引用错误
    public class CheckLogin : IHttpHandler, System.Web.SessionState.IRequiresSessionState
    {
        public static readonly string connStr
            = WebConfigurationManager.ConnectionStrings["AccessConnectionString"].ConnectionString
            + HttpContext.Current.Server.MapPath
            (WebConfigurationManager.ConnectionStrings["Access_Path"].ConnectionString);

        public void ProcessRequest(HttpContext context)
        {
            context.Response.ContentType = "text/plain";
            string userName = context.Request.QueryString["username"];
            string userPass = context.Request.QueryString["password"];

            OleDbConnection conn = new OleDbConnection(connStr);
            try
            {
                //连接access数据库
                conn.Open();
                string sql = "select * from users";
                OleDbDataAdapter myadapter =
                    new OleDbDataAdapter(sql, conn);
                DataSet ds = new DataSet();
                myadapter.Fill(ds, "users");
                conn.Close();


                foreach (DataRow dr in ds.Tables["users"].Rows)
                {
                    if (userName != dr["username"].ToString())
                    {
                        continue;
                    }
                    else
                    {
                        if (userPass != dr["password"].ToString())
                        {
                            continue;
                        }
                        else
                        {
                            context.Response.Write("ok"); //如果验证成功则返回ok

                            //记录用户登录信息
                            context.Session["IsLogin"] = "true";
                            context.Session["currentUser"] = userName;
                            return;
                        }
                    }
                }
                context.Response.Write("fail");//如果验证失败则返回fail 
                context.Session["IsLogin"] = "fasle";
            }
            catch (Exception exe)
            {
                context.Response.Write("fail");//如果验证失败则返回fail 
                context.Session["IsLogin"] = "fasle";
            }
            context.Response.End();
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
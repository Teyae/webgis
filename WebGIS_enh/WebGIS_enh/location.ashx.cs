using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

using System.Web.SessionState;
using System.Web.Configuration;

using System.Data;
using System.Data.OleDb;

using System.Text;

namespace WebGIS_enh
{
    /// <summary>
    /// location 的摘要说明
    /// </summary>
    public class location : IHttpHandler
    {
        public static readonly string connStr = WebConfigurationManager.ConnectionStrings["AccessConnectionString"].ConnectionString + HttpContext.Current.Server.MapPath(WebConfigurationManager.ConnectionStrings["Access_Path"].ConnectionString);//配置连接
        public void ProcessRequest(HttpContext context)
        {
            context.Response.ContentType = "text/plain";
            context.Response.Cache.SetNoStore();

            string LocationText = context.Request.QueryString["LocationText"];
            StringBuilder sb = new StringBuilder("[");
            string tp1 = "\"poiName\":'{0}',\"lon\":{1},\"lat\":{2}";
            OleDbConnection conn = new OleDbConnection(connStr);
            try
            {
                //连接access数据库
                conn.Open();
                string sql = "select * from POI where poiName like '%" + LocationText + "%'";   //try catch在一定程度上会slow你的程序
                OleDbDataAdapter myadapter = new OleDbDataAdapter(sql, conn);
                DataSet ds = new DataSet();
                myadapter.Fill(ds, "points");
                conn.Close();

                foreach (DataRow dr in ds.Tables["points"].Rows)
                {
                    sb.Append("{" + string.Format(tp1, dr["poiName"], dr["lon"], dr["lat"] + "},"));
                }

                context.Response.Write(sb.ToString().Substring(0, sb.ToString().Length - 1) + "]");
            }
            catch (Exception exe)
            {
                context.Response.Write("fail");
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
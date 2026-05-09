using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using System.Data.SqlClient;

namespace TelifHaklariUI
{
    public class DatabaseHelper
    {
        private string connectionString =
            @"Server=localhost;
              Database=Telif_Haklari;
              Trusted_Connection=True;";// connection string of my computer may not work on other devices

        public SqlConnection GetConnection()
        {
            return new SqlConnection(connectionString);
        }
    }
}
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Data.SqlClient;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace TelifHaklariUI
{
    public partial class FormMain : Form
    {
        public FormMain()
        {
            InitializeComponent();
        }

        private void btnShowWorks_Click(object sender, EventArgs e)
        {
            DatabaseHelper db = new DatabaseHelper();

            SqlConnection conn = db.GetConnection();

            SqlDataAdapter da =
                new SqlDataAdapter("SELECT * FROM eserler", conn);

            DataTable dt = new DataTable();

            da.Fill(dt);

            dataGridView1.DataSource = dt;
        }


        private void btnShowAdminon_Click_1(object sender, EventArgs e)
        {
            DatabaseHelper db = new DatabaseHelper();

            SqlConnection conn = db.GetConnection();

            SqlDataAdapter da =
                new SqlDataAdapter("select * from kullanicilar", conn);

            DataTable dt = new DataTable();

            da.Fill(dt);

            dataGridView1.DataSource = dt;
        }
    }
}

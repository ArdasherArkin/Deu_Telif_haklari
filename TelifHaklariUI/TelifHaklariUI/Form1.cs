using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using System.Data.SqlClient;

namespace TelifHaklariUI
{
    public partial class FormLogin : Form
    {
        DatabaseHelper db = new DatabaseHelper();

        public FormLogin()
        {
            InitializeComponent();
        }

        private void btnLogin_Click(object sender, EventArgs e)
        {
            SqlConnection conn = db.GetConnection();

            try
            {
                conn.Open();

                string query =
                "SELECT * FROM kullanicilar " +
                "WHERE kullaniciAdi=@user AND sifre=@pass";

                SqlCommand cmd = new SqlCommand(query, conn);

                cmd.Parameters.AddWithValue("@user", txtUsername.Text);
                cmd.Parameters.AddWithValue("@pass", txtPassword.Text);

                SqlDataReader dr = cmd.ExecuteReader();

                if (dr.Read())//checking before going into mainform
                {
                    MessageBox.Show("Login Successful!");

                    FormMain fm = new FormMain();
                    fm.Show();

                    this.Hide();
                }
                else
                {
                    MessageBox.Show("Wrong username or password!");
                }

                conn.Close();
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message);
            }
        }


        private void txtPassword_TextChanged(object sender, EventArgs e)
        {

        }
    }
}
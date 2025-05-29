import streamlit as st
import cx_Oracle
import pandas as pd

# Initialize session variables
if "logged_in" not in st.session_state:
    st.session_state.logged_in = False
if "connection" not in st.session_state:
    st.session_state.connection = None

# Function to show the login form
def show_login():
    st.title("🔐 Oracle Database Login")

    with st.form("login_form"):
        username = st.text_input("Username")
        password = st.text_input("Password", type="password")
        submitted = st.form_submit_button("Connect")

    if submitted:
        try:
            dsn = cx_Oracle.makedsn("localhost", 1521, sid="orcl1")
            connection = cx_Oracle.connect(user=username, password=password, dsn=dsn)

            # Store session variables
            st.session_state.logged_in = True
            st.session_state.connection = connection

            # Redirect by rerunning to show next page
            st.success("✅ Connected!")
            st.rerun()

        except cx_Oracle.DatabaseError as e:
            error, = e.args
            st.error(f"❌ Connection failed: {error.message}")

# Function to show the dashboard (after login)
def show_dashboard():
    st.title("🎛️ Dashboard")
    st.write("Welcome! Choose an action:")

    if st.button("View Hall Table"):
        st.session_state.page = "hall"
        st.rerun()
    if st.button("Run Custom Query"):
        st.session_state.page = "custom_query"
        st.rerun()
    if st.button("Logout"):
        st.session_state.logged_in = False
        st.session_state.connection = None
        st.session_state.page = "login"
        st.rerun()

# Function to show a table

def show_hall_table():
    st.title("📋 Hall Table")
    try:
        cursor = st.session_state.connection.cursor()
        cursor.execute("SELECT * FROM C##CSE464.halltable ")
        rows = cursor.fetchall()
        columns = [desc[0] for desc in cursor.description]

        # ✅ Convert to Pandas DataFrame
        df = pd.DataFrame(rows, columns=columns)
        st.dataframe(df)

        if st.button("⬅️ Back"):
            st.session_state.page = "dashboard"
            st.rerun()

    except Exception as e:
        st.error(f"Error fetching table: {e}")

    except Exception as e:
        st.error(f"Error fetching table: {e}")


def show_custom_table():
    st.title("📋 Custom Query Runner")

    # Form for custom SQL input
    with st.form("custom_table_form"):
        query = st.text_area("Enter your SQL query:")
        submitted = st.form_submit_button("Run Query")

    if submitted:
        if not query.strip().lower().startswith("select"):
            st.error("Only SELECT queries are allowed.")
            return

        try:
            cursor = st.session_state.connection.cursor()
            cursor.execute(query)
            rows = cursor.fetchall()
            columns = [desc[0] for desc in cursor.description]

            # Convert results to DataFrame
            df = pd.DataFrame(rows, columns=columns)
            st.dataframe(df)

        except Exception as e:
            st.error(f"❌ Error executing query: {e}")

    # Navigation button
    if st.button("⬅️ Back to Dashboard"):
        st.session_state.page = "dashboard"
        st.rerun()
# Page control logic
if "page" not in st.session_state:
    st.session_state.page = "login"

# Routing
if not st.session_state.logged_in:
    show_login()
else:
    if st.session_state.page == "dashboard":
        show_dashboard()
    elif st.session_state.page == "hall":
        show_hall_table()
    elif st.session_state.page == "custom_query":
        show_custom_table()
    else:
        st.session_state.page = "dashboard"
        st.rerun()

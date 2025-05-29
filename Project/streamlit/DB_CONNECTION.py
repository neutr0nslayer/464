import streamlit as st
import cx_Oracle
import pandas as pd
st.set_page_config(layout="wide")

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

            # Store session connection
            st.session_state.logged_in = True
            st.session_state.connection = connection
            st.session_state.username = username.upper()  # Save username (Oracle is case-insensitive by default)

            # Check role privileges
            cursor = connection.cursor()
            cursor.execute("SELECT role FROM sys.user_role WHERE username = :username", [st.session_state.username])
            roles = [row[0] for row in cursor.fetchall()]

            print(f"Roles for {st.session_state.username}: {roles}")  # <-- Debug print

            # If user has the role, mark them as admin
            if "admin" in roles:
                st.session_state.role = "admin"
            else:
                st.session_state.role = "user"

            st.success("✅ Connected!")
            st.rerun()

        except cx_Oracle.DatabaseError as e:
            error, = e.args
            st.error(f"❌ Connection failed: {error.message}")


# Function to show the dashboard (after login)
def show_dashboard():
    st.title("🎛️ Dashboard")
    
    st.write( st.session_state.get("role"))

    st.write("Welcome! Choose an action:")

    if st.button("View Hall Table"):
        st.session_state.page = "hall"
        st.rerun()
    if st.button("Run Custom Query"):
        st.session_state.page = "custom_query"
        st.rerun()
    if st.button("View Movie Slots"):
        st.session_state.page = "movie_slots"
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

import altair as alt

def show_movie_slots():
    st.title("🎬 Movie Slot Information")

    try:
        cursor = st.session_state.connection.cursor()

        # Fetch movie and hall names for dropdowns (same as before)...
        cursor.execute("SELECT DISTINCT moviename FROM C##CSE464.movietable ORDER BY moviename")
        movie_names = [row[0] for row in cursor.fetchall()]
        movie_names.insert(0, "All Movies")

        cursor.execute("SELECT DISTINCT hallname FROM C##CSE464.halltable ORDER BY hallname")
        hall_names = [row[0] for row in cursor.fetchall()]
        hall_names.insert(0, "All Halls")

        with st.form("movie_slot_form"):
            selected_movie = st.selectbox("Select Movie", movie_names)
            selected_hall = st.selectbox("Select Hall", hall_names)
            col1, col2 = st.columns(2)
            with col1:
                start_date = st.date_input("Start Date", value=None)
            with col2:
                end_date = st.date_input("End Date", value=None)
            submitted = st.form_submit_button("Search")

        if submitted:
            query = """
                SELECT 
                    s.slotid,
                    m.moviename,
                    s.slot,
                    s."date" AS slot_date,
                    h.hallname,
                    h.type AS hall_type,
                    s.price,
                    COUNT(t.ticketid) AS tickets_sold,
                    COUNT(t.ticketid) * s.price AS total_revenue
                FROM 
                    C##CSE464.slottable s
                JOIN 
                    C##CSE464.movietable m ON s.movietable_movieid = m.movieid
                JOIN 
                    C##CSE464.ticket t ON t.slottable_slotid = s.slotid
                JOIN
                    C##CSE464.halltable h ON s.halltable_hallid = h.hallid
                WHERE 
                    1=1
            """
            filters = []
            params = {}

            if selected_movie != "All Movies":
                filters.append("LOWER(m.moviename) LIKE :movie_name")
                params["movie_name"] = f"%{selected_movie.lower()}%"

            if selected_hall != "All Halls":
                filters.append("LOWER(h.hallname) = :hall_name")
                params["hall_name"] = selected_hall.lower()

            if start_date:
                filters.append("s.\"date\" >= TO_DATE(:start_date, 'YYYY-MM-DD')")
                params["start_date"] = start_date.strftime("%Y-%m-%d")

            if end_date:
                filters.append("s.\"date\" <= TO_DATE(:end_date, 'YYYY-MM-DD')")
                params["end_date"] = end_date.strftime("%Y-%m-%d")

            if filters:
                query += " AND " + " AND ".join(filters)

            query += """
                GROUP BY 
                    s.slotid, s.slot, s."date", m.moviename, s.price, h.type, h.hallname
                ORDER BY 
                    s."date", s.slot
            """

            cursor.execute(query, params)
            rows = cursor.fetchall()
            columns = [desc[0] for desc in cursor.description]

            if rows:
                df = pd.DataFrame(rows, columns=columns)
                st.dataframe(df, width=900)  # specify width in pixels


                # Aggregate tickets sold per date
                tickets_per_date = df.groupby('SLOT_DATE')['TICKETS_SOLD'].sum().reset_index()

                # Create line chart with Altair
                line_chart = alt.Chart(tickets_per_date).mark_line(point=True).encode(
                    x=alt.X('SLOT_DATE:T', title='Date'),
                    y=alt.Y('TICKETS_SOLD:Q', title='Tickets Sold'),
                    tooltip=['SLOT_DATE', 'TICKETS_SOLD']
                ).properties(
                    title='Tickets Sold per Date',
                    width=700,
                    height=400
                )

                st.altair_chart(line_chart, use_container_width=True)

            else:
                st.info("No slots found for the given movie name.")

    except Exception as e:
        st.error(f"❌ Error: {e}")

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
    
    # This is a hall table. you can view all the hall information.
    elif st.session_state.page == "hall":
        show_hall_table()
        
    # This is a custom query runner. you can run any query you want.
    elif st.session_state.page == "custom_query":
        show_custom_table()
        
    # This is a provence of the movie slot information. you can view all the ticket sold for a specific movie.
    elif st.session_state.page == "movie_slots":
        show_movie_slots()
    else:
        st.session_state.page = "dashboard"
        st.rerun()

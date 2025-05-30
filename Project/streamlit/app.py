import streamlit as st
import cx_Oracle
import pandas as pd
import altair as alt
from datetime import time

st.set_page_config(page_title="Ticket Dashboard", layout="wide")

# === Session Initialization ===
if "logged_in" not in st.session_state:
    st.session_state.logged_in = False
if "connection" not in st.session_state:
    st.session_state.connection = None
if "page" not in st.session_state:
    st.session_state.page = "login"
if "role" not in st.session_state:
    st.session_state.role = None

# === Oracle DSN ===
def get_dsn():
    return cx_Oracle.makedsn("localhost", 1521, sid="orcl1")

# === DB Connection Helper ===
def get_connection(user, password):
    return cx_Oracle.connect(user=user, password=password, dsn=get_dsn())

# === LOGIN PAGE ===
def show_login():
    st.title("🔐 Oracle DB Login")
    left, center, right = st.columns([.2, 2, .2])

    with center:
        with st.form("login_form"):
            username = st.text_input("Username")
            password = st.text_input("Password", type="password")
            submitted = st.form_submit_button("Connect")

        if submitted:
            try:
                connection = get_connection(username, password)
                st.session_state.connection = connection
                st.session_state.logged_in = True
                st.session_state.username = username.upper()

                # Role detection
                cursor = connection.cursor()
                cursor.execute("SELECT role FROM sys.user_role WHERE username = :username", [username.upper()])
                roles = [row[0].lower() for row in cursor.fetchall()]
                st.session_state.role = "admin" if "admin" in roles else "user"

                st.session_state.page = "dashboard"
                st.rerun()
            except cx_Oracle.DatabaseError as e:
                st.error(f"\u274c Connection failed: {e}")

# === HALL TABLE VIEW ===
def show_hall_table():
    st.title("📋 Hall Table")
    try:
        cursor = st.session_state.connection.cursor()
        cursor.execute("SELECT * FROM C##CSE464.halltable")
        df = pd.DataFrame(cursor.fetchall(), columns=[desc[0] for desc in cursor.description])
        st.dataframe(df)
    except Exception as e:
        st.error(f"Error fetching table: {e}")

# === CUSTOM QUERY PAGE ===
def show_custom_table():
    st.title("📋 Custom Query")
    with st.form("custom_query_form"):
        query = st.text_area("Enter SQL (SELECT only):")
        submit = st.form_submit_button("Run Query")
    if submit:
        if not query.strip().lower().startswith("select"):
            st.error("Only SELECT queries are allowed.")
            return
        try:
            cursor = st.session_state.connection.cursor()
            cursor.execute(query)
            df = pd.DataFrame(cursor.fetchall(), columns=[desc[0] for desc in cursor.description])
            st.dataframe(df)
        except Exception as e:
            st.error(f"Error executing query: {e}")

# === MOVIE SLOT INFO ===
def show_movie_slots():
    st.title("🎬 Movie Slot Info")
    try:
        cursor = st.session_state.connection.cursor()
        cursor.execute("SELECT DISTINCT moviename FROM C##CSE464.movietable ORDER BY moviename")
        movie_names = ["All Movies"] + [row[0] for row in cursor.fetchall()]

        cursor.execute("SELECT DISTINCT hallname FROM C##CSE464.halltable ORDER BY hallname")
        hall_names = ["All Halls"] + [row[0] for row in cursor.fetchall()]

        with st.form("slot_form"):
            selected_movie = st.selectbox("Movie", movie_names)
            selected_hall = st.selectbox("Hall", hall_names)
            col1, col2 = st.columns(2)
            with col1:
                enable_start = st.checkbox("Filter by Start Date") 
                start_date = st.date_input("Start Date") if enable_start else None
            with col2:
                enable_end = st.checkbox("Filter by End Date")
                end_date = st.date_input("End Date") if enable_end else None

            submitted = st.form_submit_button("Search")

        if submitted:
            query = """
                SELECT 
                    s.slotid, m.moviename, s.slot, s."date" AS slot_date, 
                    h.hallname, h.type AS hall_type, s.price,
                    COUNT(DISTINCT t.ticketid) AS tickets_sold,
                    COUNT(se.seatno) AS seats_sold,
                    COUNT(se.seatno) * s.price AS total_revenue
                FROM 
                    C##CSE464.slottable s
                JOIN C##CSE464.movietable m ON s.movietable_movieid = m.movieid
                JOIN C##CSE464.ticket t ON t.slottable_slotid = s.slotid
                JOIN C##CSE464.halltable h ON s.halltable_hallid = h.hallid
                JOIN C##CSE464.seattable se ON se.ticket_ticketid = t.ticketid
                WHERE 1=1
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
                    s.slotid, m.moviename, s.slot, s."date", h.hallname, h.type, s.price
                ORDER BY 
                    s."date", s.slot
            """

            cursor.execute(query, params)
            rows = cursor.fetchall()
            columns = [desc[0] for desc in cursor.description]

            if rows:
                df = pd.DataFrame(rows, columns=columns)
                st.dataframe(df)

                # Chart
                # line chart for seats sold per month
                df['YEAR_MONTH'] = df['SLOT_DATE'].dt.to_period('M').dt.to_timestamp()

                tickets_per_month = df.groupby('YEAR_MONTH')['SEATS_SOLD'].sum().reset_index()

                chart = alt.Chart(tickets_per_month).mark_line(point=True).encode(
                    x=alt.X('YEAR_MONTH:T', title='Month'),
                    y=alt.Y('SEATS_SOLD:Q', title='Seats Sold'),
                    tooltip=[alt.Tooltip('YEAR_MONTH:T', title='Month'), alt.Tooltip('SEATS_SOLD:Q')]
                ).properties(
                    title="Seats Sold per Month",
                    width=700
                )

                st.altair_chart(chart, use_container_width=True)
                
                # Pie chart for seats sold by movie
                seats_by_movie = df.groupby('MOVIENAME')['SEATS_SOLD'].sum().reset_index()

                pie_chart = alt.Chart(seats_by_movie).mark_arc().encode(
                    theta=alt.Theta(field="SEATS_SOLD", type="quantitative"),
                    color=alt.Color(field="MOVIENAME", type="nominal"),
                    tooltip=["MOVIENAME", "SEATS_SOLD"]
                ).properties(title="Seats Sold by Movie")

                st.altair_chart(pie_chart, use_container_width=True)
            else:
                st.info("No data found for selected filters.")

    except Exception as e:
        st.error(f"Error: {e}")

# === ADD MOVIE ===
def show_add_movie():
    st.header("🎥 Add New Movie")
    with st.form("add_movie_form"):
        moviename = st.text_input("Movie Name")
        releasedate = st.date_input("Release Date")
        genre = st.selectbox("Genre", ["Action", "Comedy", "Drama", "Horror", "Romance", "Sci-Fi", "Thriller", "Documentary"])
        movierating = st.number_input("Rating", 0.0, 10.0)
        rating = st.selectbox("Parental Rating", ["G", "PG", "PG-13", "R", "NC-17"])
        poster = st.text_input("Poster URL")
        submit = st.form_submit_button("Add Movie")

        if submit:
            try:
                cursor = st.session_state.connection.cursor()
                cursor.execute("""
                    INSERT INTO C##CSE464.MOVIETABLE 
                    (movieid, moviename, releasedate, genre, movierating, rating, poster)
                    VALUES (
                        (SELECT NVL(MAX(movieid), 0) + 1 FROM C##CSE464.MOVIETABLE),
                        :moviename, :releasedate, :genre, :movierating, :rating, :poster
                    )
                """, {
                    "moviename": moviename, "releasedate": releasedate,
                    "genre": genre, "movierating": movierating,
                    "rating": rating, "poster": poster
                })
                st.session_state.connection.commit()
                st.success("Movie added!")
            except Exception as e:
                st.error(f"Failed to add movie: {e}")

# === ASSIGN SLOT ===
def show_assign_slot():
    st.header("🎫 Assign Movie Slot")
    try:
        cursor = st.session_state.connection.cursor()
        cursor.execute("SELECT movieid, moviename FROM C##CSE464.MOVIETABLE")
        movies = {name: mid for mid, name in cursor.fetchall()}
        cursor.execute("SELECT hallid, hallname FROM C##CSE464.HALLTABLE")
        halls = {name: hid for hid, name in cursor.fetchall()}

        with st.form("assign_slot_form"):
            movie = st.selectbox("Movie", list(movies.keys()))
            hall = st.selectbox("Hall", list(halls.keys()))
            slot_date = st.date_input("Slot Date")
            slot_time = st.selectbox("Time", [f"{h:02d}:00" for h in range(0, 24, 2)])
            price = st.number_input("Ticket Price", 0)
            submit = st.form_submit_button("Assign")

        if submit:
            cursor.execute("""
                INSERT INTO C##CSE464.SLOTTABLE 
                (slotid, "date", movietable_movieid, halltable_hallid, slot, price)
                VALUES (
                    (SELECT NVL(MAX(slotid), 0) + 1 FROM C##CSE464.SLOTTABLE),
                    :slot_date, :movieid, :hallid, :slot, :price
                )
            """, {
                "slot_date": slot_date,  # renamed from "date" to "slot_date"
                "movieid": movies[movie],
                "hallid": halls[hall],
                "slot": slot_time,
                "price": price
            })
            st.session_state.connection.commit()
            st.success("Slot assigned successfully!")
    except Exception as e:
        st.error(f"Error assigning slot: {e}")

# === MAIN ROUTING ===
if not st.session_state.logged_in:
    show_login()
else:
    st.sidebar.title(f"Welcome, {st.session_state.username}")
    if st.sidebar.button("Logout"):
        st.session_state.logged_in = False
        st.session_state.connection = None
        st.session_state.page = "login"
        st.rerun()

    st.sidebar.subheader("Navigate")
    pages = ["Dashboard", "View Hall Table", "Run Custom Query"]
    if st.session_state.role == "admin":
        pages += ["Movie Slot Info", "Add Movie", "Assign Slot"]

    selected_page = st.sidebar.selectbox("Go to", pages, index=pages.index("Dashboard"))
    st.session_state.page = selected_page.replace(" ", "_").lower()

    # Page Routing
    page = st.session_state.page
    if page == "dashboard":
        st.title("🎬 Movie Ticket Dashboard")
        st.write("Use the sidebar to navigate between pages.")
    elif page == "view_hall_table":
        show_hall_table()
    elif page == "run_custom_query":
        show_custom_table()
    elif page == "movie_slot_info":
        show_movie_slots()
    elif page == "add_movie":
        show_add_movie()
    elif page == "assign_slot":
        show_assign_slot()

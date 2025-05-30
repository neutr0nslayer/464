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
import streamlit as st
import pandas as pd
import altair as alt

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

                # Convert slot_date column to datetime
                df['SLOT_DATE'] = pd.to_datetime(df['SLOT_DATE'], errors='coerce')

                st.dataframe(df)

                # Total Revenue Table
                total_revenue_sum = df["TOTAL_REVENUE"].sum()
                total_revenue_df = pd.DataFrame({
                    "Total": ["Total Collection "],
                    "Total Revenue": [total_revenue_sum]
                })
                st.markdown("### 💰 Total Revenue")
                st.table(total_revenue_df)

                # Chart
                df_chart = df.dropna(subset=['SLOT_DATE'])
                df_chart['YEAR_MONTH'] = df_chart['SLOT_DATE'].dt.to_period('M').dt.to_timestamp()

                tickets_per_month = df_chart.groupby('YEAR_MONTH')['SEATS_SOLD'].sum().reset_index()

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
                seats_by_movie = df_chart.groupby('MOVIENAME')['SEATS_SOLD'].sum().reset_index()

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
        
# === AUDIT RATING TABLE VIEW ===
def show_audit_ratingtable():
    st.title("🛡️ Audit Logs - Rating Table")

    try:
        cursor = st.session_state.connection.cursor()
        
        # Fetch distinct filter values
        cursor.execute("SELECT DISTINCT PERFORMED_BY FROM C##CSE464.AUDIT_RATINGTABLE ORDER BY PERFORMED_BY")
        users = ["All Users"] + [row[0] for row in cursor.fetchall()]
        
        cursor.execute("SELECT DISTINCT OPERATION_TYPE FROM C##CSE464.AUDIT_RATINGTABLE ORDER BY OPERATION_TYPE")
        operations = ["All Operations"] + [row[0] for row in cursor.fetchall()]

        cursor.execute("SELECT DISTINCT RATING_ID FROM C##CSE464.AUDIT_RATINGTABLE ORDER BY RATING_ID")
        rating_ids = ["All Rating IDs"] + [str(row[0]) for row in cursor.fetchall()]

        # UI Form
        with st.form("audit_filter_form"):
            selected_user = st.selectbox("Filter by User", users)
            selected_operation = st.selectbox("Filter by Operation", operations)
            selected_rating = st.selectbox("Filter by Rating ID", rating_ids)
            
            col1, col2 = st.columns(2)
            with col1:
                enable_start = st.checkbox("Filter by Start Time")
                start_time = st.date_input("Start Date") if enable_start else None
            with col2:
                enable_end = st.checkbox("Filter by End Time")
                end_time = st.date_input("End Date") if enable_end else None

            submitted = st.form_submit_button("Apply Filters")

        # Build Query
        query = "SELECT * FROM C##CSE464.AUDIT_RATINGTABLE WHERE 1=1"
        params = {}

        if selected_user != "All Users":
            query += " AND PERFORMED_BY = :performed_by"
            params["performed_by"] = selected_user

        if selected_operation != "All Operations":
            query += " AND OPERATION_TYPE = :operation_type"
            params["operation_type"] = selected_operation

        if selected_rating != "All Rating IDs":
            query += " AND RATING_ID = :rating_id"
            params["rating_id"] = int(selected_rating)

        if start_time:
            query += " AND OPERATION_TIME >= TO_TIMESTAMP(:start_time, 'YYYY-MM-DD HH24:MI:SS')"
            params["start_time"] = f"{start_time} 00:00:00"

        if end_time:
            query += " AND OPERATION_TIME <= TO_TIMESTAMP(:end_time, 'YYYY-MM-DD HH24:MI:SS')"
            params["end_time"] = f"{end_time} 23:59:59"

        # Execute and show
        cursor.execute(query, params)
        rows = cursor.fetchall()
        columns = [desc[0] for desc in cursor.description]

        if rows:
            df = pd.DataFrame(rows, columns=columns)
            st.dataframe(df)
        else:
            st.info("No audit records found for selected filters.")
    except Exception as e:
        st.error(f"Error retrieving audit logs: {e}")


# === MOVIE TABLE AUDIT LOG ===
def show_movietable_audit():
    st.title("🎞️ Movie Table Audit Log")

    try:
        cursor = st.session_state.connection.cursor()

        # Fetch distinct filter values for dropdowns
        cursor.execute("SELECT DISTINCT performed_by FROM movietable_audit ORDER BY performed_by")
        users = ["All Users"] + [row[0] for row in cursor.fetchall()]

        cursor.execute("SELECT DISTINCT operation_type FROM movietable_audit ORDER BY operation_type")
        operations = ["All Operations"] + [row[0] for row in cursor.fetchall()]

        cursor.execute("SELECT DISTINCT movieid FROM movietable_audit ORDER BY movieid")
        movie_ids = [row[0] for row in cursor.fetchall()]

        # Fetch movieid + moviename from movietable for filter dropdown
        cursor.execute("SELECT DISTINCT movieid, new_moviename FROM movietable_audit ORDER BY new_moviename")
        movie_options = [("All Movies", None)] + [(f"{row[1]} (ID: {row[0]})", row[0]) for row in cursor.fetchall()]

        # Filters (instant update)
        selected_user = st.selectbox("Filter by User", users)
        selected_operation = st.selectbox("Filter by Operation", operations)

        movie_names = [opt[0] for opt in movie_options]
        selected_movie_display = st.selectbox("Filter by Movie", movie_names)

        # Map selected movie display text back to movieid or None
        selected_movieid = None
        for name, mid in movie_options:
            if name == selected_movie_display:
                selected_movieid = mid
                break

        col1, col2 = st.columns(2)
        with col1:
            enable_start = st.checkbox("Filter by Start Date")
            start_date = st.date_input("Start Date") if enable_start else None
        with col2:
            enable_end = st.checkbox("Filter by End Date")
            end_date = st.date_input("End Date") if enable_end else None

        # Build query and params dynamically
        query = """
            SELECT 
                a.audit_id,
                a.operation_type,
                a.movieid,
                m.moviename,
                a.old_moviename,
                a.new_moviename,
                a.old_releasedate,
                a.new_releasedate,
                a.old_genre,
                a.new_genre,
                a.old_movierating,
                a.new_movierating,
                a.old_rating,
                a.new_rating,
                a.poster,
                a.performed_by,
                a.operation_time,
                a.user_ip_address,
                a.session_user,
                a.host_name
            FROM movietable_audit a
            LEFT JOIN movietable m ON a.movieid = m.movieid
            WHERE 1=1
        """
        params = {}

        if selected_user != "All Users":
            query += " AND a.performed_by = :performed_by"
            params["performed_by"] = selected_user

        if selected_operation != "All Operations":
            query += " AND a.operation_type = :operation_type"
            params["operation_type"] = selected_operation

        if selected_movieid is not None:
            query += " AND a.movieid = :movieid"
            params["movieid"] = selected_movieid

        if start_date:
            query += " AND a.operation_time >= TO_TIMESTAMP(:start_time, 'YYYY-MM-DD HH24:MI:SS')"
            params["start_time"] = f"{start_date} 00:00:00"

        if end_date:
            query += " AND a.operation_time <= TO_TIMESTAMP(:end_time, 'YYYY-MM-DD HH24:MI:SS')"
            params["end_time"] = f"{end_date} 23:59:59"

        query += " ORDER BY a.audit_id DESC"

        cursor.execute(query, params)
        rows = cursor.fetchall()
        columns = [desc[0] for desc in cursor.description]

        if rows:
            df = pd.DataFrame(rows, columns=columns)
            df["OPERATION_TIME"] = pd.to_datetime(df["OPERATION_TIME"])

            st.markdown(f"### 📄 Showing {len(df)} audit records")

            # Column selector UI
            st.markdown("### 🧩 Choose Columns to Display")
            selected_cols = []
            col_chunks = [df.columns[i:i+5] for i in range(0, len(df.columns), 5)]
            for chunk in col_chunks:
                cols_ui = st.columns(len(chunk))
                for i, col in enumerate(chunk):
                    if cols_ui[i].checkbox(col, value=True):
                        selected_cols.append(col)

            st.dataframe(df[selected_cols], use_container_width=True)
        else:
            st.info("No audit records found for the selected filters.")

    except Exception as e:
        st.error(f"Error loading movie table audit logs: {e}")



# === HALL TABLE AUDIT LOG ===
def show_halltable_audit():
    st.title("📝 Hall Table Audit Log")

    try:
        cursor = st.session_state.connection.cursor()

        # Fetch distinct filter values for dropdowns
        cursor.execute("SELECT DISTINCT performed_by FROM C##CSE464.halltable_audit ORDER BY performed_by")
        users = ["All Users"] + [row[0] for row in cursor.fetchall()]

        cursor.execute("SELECT DISTINCT operation_type FROM C##CSE464.halltable_audit ORDER BY operation_type")
        operations = ["All Operations"] + [row[0] for row in cursor.fetchall()]

        # Instead of hallid alone, fetch hallid + hallname from halltable for filter dropdown
        cursor.execute("SELECT DISTINCT hallid, new_hallname FROM C##CSE464.halltable_audit ORDER BY new_hallname")
        hall_options = [("All Halls", None)] + [(f"{row[1]} (ID: {row[0]})", row[0]) for row in cursor.fetchall()]

        # Filters (no form, instant update)
        selected_user = st.selectbox("Filter by User", users)
        selected_operation = st.selectbox("Filter by Operation", operations)

        hall_names = [opt[0] for opt in hall_options]
        selected_hall_display = st.selectbox("Filter by Hall", hall_names)

        # Map selected hall display text back to hallid or None
        selected_hallid = None
        for name, hid in hall_options:
            if name == selected_hall_display:
                selected_hallid = hid
                break

        col1, col2 = st.columns(2)
        with col1:
            enable_start = st.checkbox("Filter by Start Date")
            start_date = st.date_input("Start Date") if enable_start else None
        with col2:
            enable_end = st.checkbox("Filter by End Date")
            end_date = st.date_input("End Date") if enable_end else None

        # Build query and params dynamically with join to get hallname
        query = """
            SELECT a.*, h.hallname
            FROM C##CSE464.halltable_audit a
            LEFT JOIN C##CSE464.halltable h ON a.hallid = h.hallid
            WHERE 1=1
        """
        params = {}

        if selected_user != "All Users":
            query += " AND a.performed_by = :performed_by"
            params["performed_by"] = selected_user

        if selected_operation != "All Operations":
            query += " AND a.operation_type = :operation_type"
            params["operation_type"] = selected_operation

        if selected_hallid is not None:
            query += " AND a.hallid = :hallid"
            params["hallid"] = selected_hallid

        if start_date:
            query += " AND a.operation_time >= TO_TIMESTAMP(:start_time, 'YYYY-MM-DD HH24:MI:SS')"
            params["start_time"] = f"{start_date} 00:00:00"

        if end_date:
            query += " AND a.operation_time <= TO_TIMESTAMP(:end_time, 'YYYY-MM-DD HH24:MI:SS')"
            params["end_time"] = f"{end_date} 23:59:59"

        query += " ORDER BY a.operation_time DESC"

        cursor.execute(query, params)
        rows = cursor.fetchall()
        columns = [desc[0] for desc in cursor.description]

        if rows:
            df = pd.DataFrame(rows, columns=columns)
            df["OPERATION_TIME"] = pd.to_datetime(df["OPERATION_TIME"])

            # Put HALLNAME right after HALLID for easier reading
            cols = list(df.columns)
            if "HALLNAME" in cols and "HALLID" in cols:
                cols.remove("HALLNAME")
                hallid_index = cols.index("HALLID")
                cols.insert(hallid_index + 1, "HALLNAME")
                df = df[cols]

            st.markdown(f"### 📄 Showing {len(df)} audit records")

            # Column selector UI
            st.markdown("### 🧩 Choose Columns to Display")
            selected_cols = []
            col_chunks = [df.columns[i:i+5] for i in range(0, len(df.columns), 5)]
            for chunk in col_chunks:
                cols_ui = st.columns(len(chunk))
                for i, col in enumerate(chunk):
                    if cols_ui[i].checkbox(col, value=True):
                        selected_cols.append(col)

            st.dataframe(df[selected_cols], use_container_width=True)
        else:
            st.info("No audit records found for the selected filters.")

    except Exception as e:
        st.error(f"Error loading hall table audit logs: {e}")


def show_slottable_audit():
    st.title("🎫 Slot Table Audit Log")

    try:
        cursor = st.session_state.connection.cursor()

        # Fetch distinct values for filters
        cursor.execute("SELECT DISTINCT performed_by FROM C##CSE464.slottable_audit ORDER BY performed_by")
        users = ["All Users"] + [row[0] for row in cursor.fetchall()]

        cursor.execute("SELECT DISTINCT operation_type FROM C##CSE464.slottable_audit ORDER BY operation_type")
        operations = ["All Operations"] + [row[0] for row in cursor.fetchall()]

        cursor.execute("SELECT movieid, moviename FROM C##CSE464.movietable ORDER BY moviename")
        movies = [("All Movies", None)] + [(f"{row[1]} (ID: {row[0]})", row[0]) for row in cursor.fetchall()]

        cursor.execute("SELECT hallid, hallname FROM C##CSE464.halltable ORDER BY hallname")
        halls = [("All Halls", None)] + [(f"{row[1]} (ID: {row[0]})", row[0]) for row in cursor.fetchall()]

        # === Filters UI ===
        selected_user = st.selectbox("Filter by User", users)
        selected_operation = st.selectbox("Filter by Operation", operations)

        selected_movie_display = st.selectbox("Filter by Movie", [m[0] for m in movies])
        selected_movieid = next((mid for name, mid in movies if name == selected_movie_display), None)

        selected_hall_display = st.selectbox("Filter by Hall", [h[0] for h in halls])
        selected_hallid = next((hid for name, hid in halls if name == selected_hall_display), None)

        slotid_input = st.text_input("Slot ID (exact match, leave blank to search all)")

        col1, col2 = st.columns(2)
        with col1:
            enable_start = st.checkbox("Filter by Start Date")
            start_date = st.date_input("Start Date") if enable_start else None
        with col2:
            enable_end = st.checkbox("Filter by End Date")
            end_date = st.date_input("End Date") if enable_end else None

        # === Price Slider ===
        st.markdown("### 🎯 Filter by Ticket Price")
        price_min, price_max = st.slider("Select Price Range", 0, 1000, (0, 1000), step=10)

        # Get slot IDs from slottable within price range
        cursor.execute("""
            SELECT slotid FROM C##CSE464.slottable
            WHERE price BETWEEN :min_price AND :max_price
        """, {"min_price": price_min, "max_price": price_max})
        slotids_from_price = [row[0] for row in cursor.fetchall()]
        if not slotids_from_price:
            slotids_from_price = [-1]  # dummy value to avoid empty IN clause

        # === Build dynamic SQL query ===
        slotid_placeholders = ", ".join([f":slotid_{i}" for i in range(len(slotids_from_price))])
        query = f"SELECT * FROM C##CSE464.slottable_audit WHERE slotid IN ({slotid_placeholders})"
        params = {f"slotid_{i}": sid for i, sid in enumerate(slotids_from_price)}

        # Add other filters
        if selected_user != "All Users":
            query += " AND performed_by = :performed_by"
            params["performed_by"] = selected_user

        if selected_operation != "All Operations":
            query += " AND operation_type = :operation_type"
            params["operation_type"] = selected_operation

        if selected_movieid is not None:
            query += " AND (old_movieid = :movieid OR new_movieid = :movieid)"
            params["movieid"] = selected_movieid

        if selected_hallid is not None:
            query += " AND (old_hallid = :hallid OR new_hallid = :hallid)"
            params["hallid"] = selected_hallid

        if slotid_input.strip():
            try:
                sid = int(slotid_input.strip())
                query += " AND slotid = :slotid"
                params["slotid"] = sid
            except ValueError:
                st.error("Slot ID must be an integer.")
                return

        if start_date:
            query += " AND operation_time >= TO_TIMESTAMP(:start_time, 'YYYY-MM-DD HH24:MI:SS')"
            params["start_time"] = f"{start_date} 00:00:00"

        if end_date:
            query += " AND operation_time <= TO_TIMESTAMP(:end_time, 'YYYY-MM-DD HH24:MI:SS')"
            params["end_time"] = f"{end_date} 23:59:59"

        query += " ORDER BY operation_time DESC"

        # === Execute & Display ===
        cursor.execute(query, params)
        rows = cursor.fetchall()
        columns = [desc[0] for desc in cursor.description]

        if rows:
            df = pd.DataFrame(rows, columns=columns)
            df["OPERATION_TIME"] = pd.to_datetime(df["OPERATION_TIME"])
            st.markdown(f"### 📄 Showing {len(df)} audit records")

            # Column Selector
            st.markdown("### 🧩 Choose Columns to Display")
            selected_cols = []
            col_chunks = [df.columns[i:i+5] for i in range(0, len(df.columns), 5)]
            for chunk in col_chunks:
                cols_ui = st.columns(len(chunk))
                for i, col in enumerate(chunk):
                    if cols_ui[i].checkbox(col, value=True):
                        selected_cols.append(col)

            st.dataframe(df[selected_cols], use_container_width=True)
        else:
            st.info("No audit records found for selected filters.")

    except Exception as e:
        st.error(f"Error loading slot table audit logs: {e}")

# === SEAT TABLE AUDIT LOG ===
def show_seattable_audit():
    st.title("🪑 Seat Table Audit Log")

    try:
        cursor = st.session_state.connection.cursor()

        # Fetch distinct filter values dynamically
        cursor.execute("SELECT DISTINCT performed_by FROM C##CSE464.seattable_audit ORDER BY performed_by")
        users = ["All Users"] + [row[0] for row in cursor.fetchall()]

        cursor.execute("SELECT DISTINCT operation_type FROM C##CSE464.seattable_audit ORDER BY operation_type")
        operations = ["All Operations"] + [row[0] for row in cursor.fetchall()]

        # Filters (instant update)
        selected_user = st.selectbox("Filter by User", users)
        selected_operation = st.selectbox("Filter by Operation", operations)

        ticket_id_input = st.text_input("Ticket ID (search in old or new ticketid, leave blank for all)")
        seat_no_input = st.text_input("Seat No (search in old or new seatno, leave blank for all)")

        col1, col2 = st.columns(2)
        with col1:
            enable_start = st.checkbox("Filter by Start Date")
            start_date = st.date_input("Start Date") if enable_start else None
        with col2:
            enable_end = st.checkbox("Filter by End Date")
            end_date = st.date_input("End Date") if enable_end else None

        # Build query with filters
        query = "SELECT * FROM C##CSE464.seattable_audit WHERE 1=1"
        params = {}

        if selected_user != "All Users":
            query += " AND performed_by = :performed_by"
            params["performed_by"] = selected_user

        if selected_operation != "All Operations":
            query += " AND operation_type = :operation_type"
            params["operation_type"] = selected_operation

        # Ticket ID filter (old or new)
        if ticket_id_input.strip():
            try:
                ticket_id = int(ticket_id_input.strip())
                query += " AND (old_ticketid = :ticketid OR new_ticketid = :ticketid)"
                params["ticketid"] = ticket_id
            except ValueError:
                st.error("Ticket ID must be a valid integer.")
                return

        # Seat No filter (old or new)
        if seat_no_input.strip():
            try:
                seat_no = int(seat_no_input.strip())
                query += " AND (old_seatno = :seatno OR new_seatno = :seatno)"
                params["seatno"] = seat_no
            except ValueError:
                st.error("Seat No must be a valid integer.")
                return

        if start_date:
            query += " AND operation_time >= TO_TIMESTAMP(:start_time, 'YYYY-MM-DD HH24:MI:SS')"
            params["start_time"] = f"{start_date} 00:00:00"

        if end_date:
            query += " AND operation_time <= TO_TIMESTAMP(:end_time, 'YYYY-MM-DD HH24:MI:SS')"
            params["end_time"] = f"{end_date} 23:59:59"

        query += " ORDER BY operation_time DESC"

        cursor.execute(query, params)
        rows = cursor.fetchall()
        columns = [desc[0] for desc in cursor.description]

        if rows:
            df = pd.DataFrame(rows, columns=columns)
            df["OPERATION_TIME"] = pd.to_datetime(df["OPERATION_TIME"])

            st.markdown(f"### 📄 Showing {len(df)} audit records")

            # Column selector UI
            st.markdown("### 🧩 Choose Columns to Display")
            selected_cols = []
            col_chunks = [df.columns[i:i+5] for i in range(0, len(df.columns), 5)]
            for chunk in col_chunks:
                cols_ui = st.columns(len(chunk))
                for i, col in enumerate(chunk):
                    if cols_ui[i].checkbox(col, value=True):
                        selected_cols.append(col)

            st.dataframe(df[selected_cols], use_container_width=True)
        else:
            st.info("No audit records found for the selected filters.")

        # Back button to Dashboard
        if st.button("Back to Dashboard"):
            st.session_state.page = "dashboard"
            st.experimental_rerun()

    except Exception as e:
        st.error(f"Error loading seat table audit logs: {e}")


# === TICKET AUDIT LOG ===
def show_ticket_audit():
    st.title("🎟️ Ticket Audit Log")

    try:
        cursor = st.session_state.connection.cursor()

        # Fetch distinct filter values dynamically
        cursor.execute("SELECT DISTINCT performed_by FROM C##CSE464.ticket_audit ORDER BY performed_by")
        users = ["All Users"] + [row[0] for row in cursor.fetchall()]

        cursor.execute("SELECT DISTINCT operation_type FROM C##CSE464.ticket_audit ORDER BY operation_type")
        operations = ["All Operations"] + [row[0] for row in cursor.fetchall()]

        # Filters (instant update)
        selected_user = st.selectbox("Filter by User", users)
        selected_operation = st.selectbox("Filter by Operation", operations)
        
        ticket_id_input = st.text_input("Ticket ID (leave blank to search all)")

        col1, col2 = st.columns(2)
        with col1:
            enable_start = st.checkbox("Filter by Start Date")
            start_date = st.date_input("Start Date") if enable_start else None
        with col2:
            enable_end = st.checkbox("Filter by End Date")
            end_date = st.date_input("End Date") if enable_end else None

        # Build query with filters
        query = "SELECT * FROM C##CSE464.ticket_audit WHERE 1=1"
        params = {}

        if selected_user != "All Users":
            query += " AND performed_by = :performed_by"
            params["performed_by"] = selected_user

        if selected_operation != "All Operations":
            query += " AND operation_type = :operation_type"
            params["operation_type"] = selected_operation

        # Ticket ID filter if input is not empty and valid integer
        if ticket_id_input.strip():
            try:
                ticket_id = int(ticket_id_input.strip())
                query += " AND ticketid = :ticketid"
                params["ticketid"] = ticket_id
            except ValueError:
                st.error("Ticket ID must be a valid integer.")
                return  # Stop execution if invalid ticket id

        if start_date:
            query += " AND operation_time >= TO_TIMESTAMP(:start_time, 'YYYY-MM-DD HH24:MI:SS')"
            params["start_time"] = f"{start_date} 00:00:00"

        if end_date:
            query += " AND operation_time <= TO_TIMESTAMP(:end_time, 'YYYY-MM-DD HH24:MI:SS')"
            params["end_time"] = f"{end_date} 23:59:59"

        query += " ORDER BY operation_time DESC"

        cursor.execute(query, params)
        rows = cursor.fetchall()
        columns = [desc[0] for desc in cursor.description]

        if rows:
            df = pd.DataFrame(rows, columns=columns)
            df["OPERATION_TIME"] = pd.to_datetime(df["OPERATION_TIME"])

            st.markdown(f"### 📄 Showing {len(df)} audit records")

            # Column selector UI
            st.markdown("### 🧩 Choose Columns to Display")
            selected_cols = []
            col_chunks = [df.columns[i:i+5] for i in range(0, len(df.columns), 5)]
            for chunk in col_chunks:
                cols_ui = st.columns(len(chunk))
                for i, col in enumerate(chunk):
                    if cols_ui[i].checkbox(col, value=True):
                        selected_cols.append(col)

            st.dataframe(df[selected_cols], use_container_width=True)
        else:
            st.info("No audit records found for the selected filters.")

        # Back button to Dashboard
        if st.button("Back to Dashboard"):
            st.session_state.page = "dashboard"
            st.experimental_rerun()

    except Exception as e:
        st.error(f"Error loading ticket audit logs: {e}")

def show_top_seat_users():
    st.subheader("Top 10 Users")

    try:
        cursor = st.session_state.connection.cursor()
        query = """
            SELECT u.name, COUNT(s.seatno) AS seat_count
            FROM seattable s
            JOIN ticket t ON s.ticket_ticketid = t.ticketid
            JOIN usertable u ON t.usertable_id = u.id
            GROUP BY u.name
            ORDER BY seat_count DESC
            FETCH FIRST 10 ROWS ONLY
        """
        cursor.execute(query)
        rows = cursor.fetchall()
        if not rows:
            st.info("No seat booking data found.")
            return

        df = pd.DataFrame(rows, columns=["Name", "Seat Count"])

        # Create combined label with name and count
        df["label"] = df.apply(lambda row: f"{row['Name']} ({row['Seat Count']})", axis=1)

        pie_chart = alt.Chart(df).mark_arc().encode(
            theta=alt.Theta(field="Seat Count", type="quantitative"),
            color=alt.Color(field="label", type="nominal", legend=alt.Legend(title="User (Seats Sold)")),
            tooltip=["Name", "Seat Count"]
        ).properties(
            width=600,
            height=400,
            title="Top 10 Users by Seats Booked"
        )

        st.altair_chart(pie_chart, use_container_width=True)

    except Exception as e:
        st.error(f"Error fetching top seat users: {e}")

def show_top_movies_by_seats():
    st.subheader("Top 10 Performing Movies ")

    try:
        cursor = st.session_state.connection.cursor()
        query = """
            SELECT 
                m.moviename,
                COUNT(s.seatno) AS seats_sold
            FROM C##CSE464.seattable s
            JOIN C##CSE464.ticket t ON s.ticket_ticketid = t.ticketid
            JOIN C##CSE464.slottable sl ON t.slottable_slotid = sl.slotid
            JOIN C##CSE464.movietable m ON sl.movietable_movieid = m.movieid
            GROUP BY m.moviename
            ORDER BY seats_sold DESC
            FETCH FIRST 10 ROWS ONLY
        """
        cursor.execute(query)
        rows = cursor.fetchall()
        if not rows:
            st.info("No seat sale data found.")
            return

        df = pd.DataFrame(rows, columns=["Movie Name", "Seats Sold"])

        # Create combined label with movie name and seats sold
        df["label"] = df.apply(lambda row: f"{row['Movie Name']} ({row['Seats Sold']})", axis=1)

        pie_chart = alt.Chart(df).mark_arc().encode(
            theta=alt.Theta(field="Seats Sold", type="quantitative"),
            color=alt.Color(field="label", type="nominal", legend=alt.Legend(title="Movie (Seats Sold)")),
            tooltip=["Movie Name", "Seats Sold"]
        ).properties(
            width=600,
            height=400,
            title="Top 10 Movies by Seats Sold"
        )

        st.altair_chart(pie_chart, use_container_width=True)

    except Exception as e:
        st.error(f"Error loading top movies data: {e}")

def show_top_halls_by_seats_and_revenue():
    st.subheader("Top 10 Performing Halls")

    try:
        cursor = st.session_state.connection.cursor()
        query = """
            SELECT 
                h.hallname,
                COUNT(s.seatno) AS seats_sold,
                SUM(sl.price) AS total_revenue
            FROM C##CSE464.seattable s
            JOIN C##CSE464.ticket t ON s.ticket_ticketid = t.ticketid
            JOIN C##CSE464.slottable sl ON t.slottable_slotid = sl.slotid
            JOIN C##CSE464.halltable h ON sl.halltable_hallid = h.hallid
            GROUP BY h.hallname
            ORDER BY seats_sold DESC
            FETCH FIRST 10 ROWS ONLY
        """
        cursor.execute(query)
        rows = cursor.fetchall()
        if not rows:
            st.info("No seat sale data found.")
            return

        df = pd.DataFrame(rows, columns=["Hall Name", "Seats Sold", "Total Revenue"])

        # Format revenue for legend
        df["revenue_label"] = df["Total Revenue"].map(lambda x: f"${x:,.2f}")

        # Combined label for legend: Hall Name (Seats Sold, Revenue)
        df["label"] = df.apply(lambda row: f"{row['Hall Name']} ({row['Seats Sold']} seats, {row['revenue_label']})", axis=1)

        pie_chart = alt.Chart(df).mark_arc().encode(
            theta=alt.Theta(field="Seats Sold", type="quantitative"),
            color=alt.Color(
                field="label",
                type="nominal",
                legend=alt.Legend(
                    title="Hall (Seats Sold, Revenue)",
                    titleLimit=300,
                    labelLimit=300,
                    labelFontSize=12,
                    titleFontSize=14,
                    orient="right"
                )
            ),
            tooltip=[
                alt.Tooltip("Hall Name"),
                alt.Tooltip("Seats Sold", format=",d"),
                alt.Tooltip("Total Revenue", format="$,.2f")
            ]
        ).properties(
            width=700,
            height=400,
            title="Top 10 Halls by Seats Sold and Revenue"
        )

        st.altair_chart(pie_chart, use_container_width=True)

        # Optional: show data table below chart for clarity
        # st.markdown("### Detailed Data")
        # st.dataframe(df[["Hall Name", "Seats Sold", "Total Revenue"]])

    except Exception as e:
        st.error(f"Error loading top halls data: {e}")

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
    
    # Main pages
    pages = ["Dashboard", "View Hall Table", "Run Custom Query", "Top Ticket Users"]
    if st.session_state.role == "admin":
        pages += ["Movie Slot Info", "Add Movie", "Assign Slot"]

    selected_page = st.sidebar.selectbox("Go to", pages, index=pages.index("Dashboard"))
    st.session_state.page = selected_page.replace(" ", "_").lower()

    # Separate Audit Logs Section
    if st.session_state.role == "admin":
        st.sidebar.subheader("Audit Logs")
        audit_pages = [
            "Rating Audit Logs", "Movie Audit Log", "Hall Audit Log",
            "Slot Audit Log", "Seat Audit Log", "Ticket Audit Log"
        ]
        selected_audit = st.sidebar.selectbox("View Audit Log", ["None"] + audit_pages)

        if selected_audit != "None":
            st.session_state.page = selected_audit.replace(" ", "_").lower()

    # Page Routing
    page = st.session_state.page
    if page == "dashboard":
        st.title("🎬 Movie Ticket Dashboard")
        st.write("Use the sidebar to navigate between pages.")
        show_top_seat_users()
        show_top_movies_by_seats()
        show_top_halls_by_seats_and_revenue()
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
    elif page == "rating_audit_logs":
        show_audit_ratingtable()
    elif page == "movie_audit_log":
        show_movietable_audit()
    elif page == "hall_audit_log":
        show_halltable_audit()
    elif page == "slot_audit_log":
        show_slottable_audit()
    elif page == "seat_audit_log":
        show_seattable_audit()
    elif page == "ticket_audit_log":
        show_ticket_audit()
    elif page == "top_ticket_users":
        show_top_ticket_users()

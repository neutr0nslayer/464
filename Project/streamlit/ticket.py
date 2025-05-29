import streamlit as st
import cx_Oracle
import pandas as pd
from datetime import datetime

# ---------------- DATABASE ----------------
def get_connection():
    dsn = cx_Oracle.makedsn("localhost", 1521, sid="ORCL1")
    return cx_Oracle.connect(user="C##user1", password="user1", dsn=dsn)

def authenticate_user(email, password):
    conn = get_connection()
    query = """
        SELECT id, name FROM C##CSE464.usertable
        WHERE email = :1 AND password = :2
    """
    df = pd.read_sql(query, conn, params=[email, password])
    conn.close()
    return df if not df.empty else None

def get_movies():
    conn = get_connection()
    query = "SELECT movieid, moviename FROM C##CSE464.movietable ORDER BY movieid"
    df = pd.read_sql(query, conn)
    conn.close()
    return df

def get_slots(movie_id):
    conn = get_connection()
    query = """
        SELECT slottable.slotid,
               slottable."date" AS show_date,
               slottable.slot AS show_time,
               halltable.hallname,
               slottable.price
        FROM C##CSE464.slottable slottable
        JOIN C##CSE464.halltable halltable
          ON slottable.halltable_hallid = halltable.hallid
        WHERE slottable.movietable_movieid = :1
        ORDER BY slottable."date", slottable.slot
    """
    df = pd.read_sql(query, conn, params=[int(movie_id)])
    conn.close()
    return df

def get_booked_seats(slot_id):
    conn = get_connection()
    query = """
        SELECT seatno
        FROM C##CSE464.seattable s
        JOIN C##CSE464.ticket t ON s.ticket_ticketid = t.ticketid
        WHERE t.slottable_slotid = :1
    """
    df = pd.read_sql(query, conn, params=[int(slot_id)])
    conn.close()
    return set(df["SEATNO"].tolist()) if not df.empty else set()

def book_ticket(user_id, slot_id, price, seats):
    conn = get_connection()
    cursor = conn.cursor()
    buying_date = datetime.now().date()

    ticket_id_var = cursor.var(cx_Oracle.NUMBER)
    cursor.execute("""
        INSERT INTO C##CSE464.ticket (ticketid, price, buyingdate, usertable_id, slottable_slotid)
        VALUES ((SELECT NVL(MAX(ticketid), 0) + 1 FROM C##CSE464.ticket), :1, :2, :3, :4)
        RETURNING ticketid INTO :5
    """, (int(price), buying_date, int(user_id), int(slot_id), ticket_id_var))

    ticket_id = int(ticket_id_var.getvalue()[0])  

    for seat in seats:
        cursor.execute("""
            INSERT INTO C##CSE464.seattable (seatno, ticket_ticketid)
            VALUES (:1, :2)
        """, (int(seat), ticket_id))

    conn.commit()
    conn.close()
    return ticket_id

def get_user_tickets(user_id):
    conn = get_connection()
    query = """
        SELECT t.ticketid, t.buyingdate,
               s."date" AS show_date, s.slot AS show_time,
               m.moviename, h.hallname, t.price
        FROM C##CSE464.ticket t
        JOIN C##CSE464.slottable s ON t.slottable_slotid = s.slotid
        JOIN C##CSE464.movietable m ON s.movietable_movieid = m.movieid
        JOIN C##CSE464.halltable h ON s.halltable_hallid = h.hallid
        WHERE t.usertable_id = :1
        ORDER BY t.ticketid DESC
    """
    df = pd.read_sql(query, conn, params=[user_id])
    conn.close()
    return df

# ---------------- SEAT MAP ----------------
def render_seat_map(booked_seats, total_rows=5, seats_per_row=10):
    if 'selected_seats' not in st.session_state:
        st.session_state.selected_seats = set()

    updated_selected_seats = set()

    for row in range(total_rows):
        cols = st.columns(seats_per_row)
        for i in range(seats_per_row):
            seat_no = row * seats_per_row + i + 1
            seat_label = f"Seat {seat_no}"

            if seat_no in booked_seats:
                cols[i].checkbox(seat_label, value=True, disabled=True, key=f"booked_{seat_no}")
            else:
                checked = cols[i].checkbox(seat_label, value=(seat_no in st.session_state.selected_seats), key=f"select_{seat_no}")
                if checked:
                    updated_selected_seats.add(seat_no)

    st.session_state.selected_seats = updated_selected_seats
    return list(updated_selected_seats)


# ---------------- UI START ----------------
st.set_page_config(page_title="Movie Booking", layout="wide")

# Initialize session variables
if 'user' not in st.session_state:
    st.session_state.user = None
if 'last_selected_slot_id' not in st.session_state:
    st.session_state.last_selected_slot_id = None
if 'selected_seats' not in st.session_state:
    st.session_state.selected_seats = set()

# Login screen
if st.session_state.user is None:
    st.title("🎟️ Login to Book Tickets")
    email = st.text_input("Email")
    password = st.text_input("Password", type="password")

    if st.button("Login"):
        user_data = authenticate_user(email, password)
        if user_data is not None:
            st.session_state.user = {
                "id": int(user_data.iloc[0]["ID"]),
                "name": user_data.iloc[0]["NAME"]
            }
            st.success(f"Welcome, {st.session_state.user['name']}!")
            st.rerun()  # Rerun to load the main app
        else:
            st.error("Invalid credentials")
    st.stop()

# Logged in: Sidebar for navigation and logout
page = st.sidebar.selectbox("Navigate", ["Book Tickets", "My Tickets"])

if st.sidebar.button("Logout"):
    st.session_state.user = None
    st.session_state.selected_seats = set()
    st.session_state.last_selected_slot_id = None
    st.rerun()

# Pages
if page == "Book Tickets":
    st.title("🎬 Movie Ticket Booking")

    # 1. Movie selection
    movies = get_movies()
    movie_name = st.selectbox("Select a movie", movies["MOVIENAME"])
    selected_movie_id = int(movies[movies["MOVIENAME"] == movie_name]["MOVIEID"].values[0])

    # 2. Slot selection
    slots = get_slots(selected_movie_id)
    if not slots.empty:
        slot_display = slots.apply(
            lambda row: f"{row['SHOW_DATE'].date()} | {row['SHOW_TIME']} | {row['HALLNAME']} | ${row['PRICE']}",
            axis=1
        )
        slot_choice = st.selectbox("Choose a showtime", slot_display)
        selected_slot = slots.iloc[slot_display[slot_display == slot_choice].index[0]]
        selected_slot_id = selected_slot["SLOTID"]
        price = selected_slot["PRICE"]

        # Reset selected seats if slot changed
        if st.session_state.last_selected_slot_id != selected_slot_id:
            st.session_state.selected_seats = set()
            st.session_state.last_selected_slot_id = selected_slot_id

        st.markdown(f"**Selected slot:** `{selected_slot['SHOW_DATE'].date()}` at `{selected_slot['SHOW_TIME']}` in `{selected_slot['HALLNAME']}`")
    else:
        st.warning("No slots available for this movie.")
        st.stop()

    # 3. Seat Map
    st.subheader("🪑 Choose Your Seats")
    booked_seats = get_booked_seats(selected_slot_id)
    selected_seats = render_seat_map(booked_seats)

    # 4. Confirm booking
    if st.button("Buy Ticket"):
        if not selected_seats:
            st.warning("Please select at least one seat.")
        else:
            already_booked = [s for s in selected_seats if s in booked_seats]
            if already_booked:
                st.error(f"Seats already taken: {already_booked}")
            else:
                try:
                    ticket_id = book_ticket(st.session_state.user["id"], selected_slot_id, price, selected_seats)
                    st.success(f"✅ Ticket booked successfully! Ticket ID: {ticket_id}")
                    st.session_state.selected_seats = set()
                except Exception as e:
                    st.error(f"❌ Booking failed: {e}")

elif page == "My Tickets":
    st.header("📄 My Tickets")
    tickets = get_user_tickets(st.session_state.user["id"])
    
    if not tickets.empty:
        for idx, ticket in tickets.iterrows():
            with st.expander(f"Ticket ID: {ticket['TICKETID']} - {ticket['MOVIENAME']} on {ticket['SHOW_DATE'].date()}"):
                st.markdown(f"**Hall:** {ticket['HALLNAME']}")
                st.markdown(f"**Show Time:** {ticket['SHOW_DATE'].date()} at {ticket['SHOW_TIME']}")
                st.markdown(f"**Price:** ${ticket['PRICE']}")
                
                movie_rating = st.slider(f"Rate Movie (Ticket {ticket['TICKETID']})", 0, 10, key=f"movie_{ticket['TICKETID']}")
                hall_rating = st.slider(f"Rate Hall (Ticket {ticket['TICKETID']})", 0, 10, key=f"hall_{ticket['TICKETID']}")
                
                if st.button(f"Submit Rating for Ticket {ticket['TICKETID']}"):
                    try:
                        conn = get_connection()
                        cursor = conn.cursor()
                        cursor.execute("""
                            INSERT INTO C##CSE464.ratingtable (rating_id, movie_rating, hall_ratting, ticket_ticketid)
                            VALUES (
                                (SELECT NVL(MAX(rating_id), 0) + 1 FROM C##CSE464.ratingtable),
                                :1, :2, :3
                            )
                        """, (movie_rating, hall_rating, int(ticket['TICKETID'])))
                        conn.commit()
                        conn.close()
                        st.success(f"Rating submitted for Ticket ID {ticket['TICKETID']}")
                    except Exception as e:
                        st.error(f"Error submitting rating: {e}")
    else:
        st.info("No tickets found.")


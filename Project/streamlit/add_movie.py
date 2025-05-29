import streamlit as st
import cx_Oracle
from datetime import time

# === DB Connection ===
def get_connection():
    dsn = cx_Oracle.makedsn("localhost", 1521, sid="orcl1")
    return cx_Oracle.connect(user="C##user2", password="user2", dsn=dsn)

# === Authentication ===
def authenticate(username, password):
    try:
        conn = get_connection()
        cursor = conn.cursor()
        cursor.execute("""
            SELECT password FROM C##CSE464.USERTABLE
            WHERE email = :username
        """, {"username": username})
        row = cursor.fetchone()
        cursor.close()
        conn.close()
        if row and row[0] == password:
            return True
        return False
    except Exception as e:
        st.error(f"Error authenticating: {e}")
        return False

# === Navigation ===
def main():
    # Session state for login status
    if "logged_in" not in st.session_state:
        st.session_state.logged_in = False
    if "username" not in st.session_state:
        st.session_state.username = ""

    # Login form
    if not st.session_state.logged_in:
        st.title("Login")
        email = st.text_input("Email")
        password = st.text_input("Password", type="password")
        if st.button("Login"):
            if authenticate(email, password):
                st.session_state.logged_in = True
                st.session_state.username = email
                st.success(f"Welcome {email}!")
                st.rerun()  
            else:
                st.error("Invalid username or password")
        return  # Skip rest if not logged in

    # Logged in UI
    st.sidebar.title(f"Welcome, {st.session_state.username}")
    
    # Dropdown for navigation pages except logout
    page = st.sidebar.selectbox("Navigate", ["Add Movie", "Assign Slot"])
    
    # Logout button separate from dropdown
    if st.sidebar.button("Logout"):
        st.session_state.logged_in = False
        st.session_state.username = ""
        st.rerun()

    conn = get_connection()
    cursor = conn.cursor()

    if page == "Add Movie":
        st.header("Add Movie")
        with st.form("movie_form"):
            moviename = st.text_input("Movie Name")
            releasedate = st.date_input("Release Date")

            # Genre dropdown - predefined list
            genres = [
                "Action", "Comedy", "Drama", "Horror",
                "Romance", "Sci-Fi", "Thriller", "Documentary"
            ]
            genre = st.selectbox("Genre", genres)

            movierating = st.number_input("Movie Rating (Number)", min_value=0, max_value=10)
            
            # Parental rating dropdown - predefined list
            parental_ratings = ["G", "PG", "PG-13", "R", "NC-17"]
            rating = st.selectbox("Parental Rating", parental_ratings)

            poster = st.text_input("Poster URL")
            submit_movie = st.form_submit_button("Add Movie")

            if submit_movie:
                try:
                    cursor.execute("""
                        INSERT INTO C##CSE464.MOVIETABLE (movieid, moviename, releasedate, genre, movierating, rating, poster)
                        VALUES (
                            (SELECT NVL(MAX(movieid),0) + 1 FROM C##CSE464.MOVIETABLE),
                            :moviename, :releasedate, :genre, :movierating, :rating, :poster
                        )
                    """, {
                        "moviename": moviename,
                        "releasedate": releasedate,
                        "genre": genre,
                        "movierating": movierating,
                        "rating": rating,
                        "poster": poster
                    })
                    conn.commit()
                    st.success("Movie added successfully!")
                except Exception as e:
                    st.error(f"Error adding movie: {e}")

    elif page == "Assign Slot":
        st.header("Assign Slot")
        with st.form("slot_form"):
            # Fetch movies for selection
            cursor.execute("SELECT movieid, moviename FROM C##CSE464.MOVIETABLE ORDER BY moviename")
            movies = cursor.fetchall()
            movie_options = {name: mid for mid, name in movies}
            selected_movie = st.selectbox("Select Movie", options=list(movie_options.keys()))
    
            # Fetch halls for selection
            cursor.execute("SELECT hallid, hallname FROM C##CSE464.HALLTABLE ORDER BY hallname")
            halls = cursor.fetchall()
            hall_options = {name: hid for hid, name in halls}
            selected_hall = st.selectbox("Select Hall", options=list(hall_options.keys()))
    
            slot_date = st.date_input("Slot Date")
    
            # Generate 2-hour interval time slots as strings like "00:00", "02:00", ..., "22:00"
            time_slots = [f"{hour:02d}:00" for hour in range(0, 24, 2)]
            slot_time = st.selectbox("Slot Time", options=time_slots)
    
            price = st.number_input("Price", min_value=0)
    
            submit_slot = st.form_submit_button("Assign Slot")
    
            if submit_slot:
                try:
                    cursor.execute("""
                        INSERT INTO C##CSE464.SLOTTABLE (slotid, "date", movietable_movieid, halltable_hallid, slot, price)
                        VALUES (
                            (SELECT NVL(MAX(slotid),0) + 1 FROM C##CSE464.SLOTTABLE),
                            :slot_date, :movie_id, :hall_id, :slot_time, :price
                        )
                    """, {
                        "slot_date": slot_date,
                        "movie_id": movie_options[selected_movie],
                        "hall_id": hall_options[selected_hall],
                        "slot_time": slot_time,
                        "price": price
                    })
                    conn.commit()
                    st.success("Slot assigned successfully!")
                except Exception as e:
                    st.error(f"Error assigning slot: {e}")
    cursor.close()
    conn.close()


if __name__ == "__main__":
    main()

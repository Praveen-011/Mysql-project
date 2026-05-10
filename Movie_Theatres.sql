-- Table for theatres
CREATE TABLE Theatres (
    theatre_id INT PRIMARY KEY AUTO_INCREMENT,
    theatre_name VARCHAR(100) NOT NULL,
    location VARCHAR(100) NOT NULL,
    total_screens INT NOT NULL
);

-- Table for movies
CREATE TABLE Movies (
    movie_id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(100) NOT NULL,
    genre VARCHAR(50),
    duration_minutes INT,
    rating DECIMAL(2,1) -- IMDb rating like 8.5
);

-- Table for showtimes
CREATE TABLE Showtimes (
    show_id INT PRIMARY KEY AUTO_INCREMENT,
    theatre_id INT,
    movie_id INT,
    screen_no INT,
    show_time DATETIME,
    FOREIGN KEY (theatre_id) REFERENCES Theatres(theatre_id),
    FOREIGN KEY (movie_id) REFERENCES Movies(movie_id)
);

-- Table for bookings
CREATE TABLE Bookings (
    booking_id INT PRIMARY KEY AUTO_INCREMENT,
    show_id INT,
    customer_name VARCHAR(100),
    seats_booked INT,
    booking_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (show_id) REFERENCES Showtimes(show_id)
);
............................................................................................ 
INSERT INTO Theatres (theatre_name, location, total_screens) VALUES
('PVR Cinemas', 'Hyderabad', 6),
('INOX', 'Bangalore', 8),
('Cinepolis', 'Chennai', 7),
('Asian Cinemas', 'Hyderabad', 5),
('Prasads IMAX', 'Hyderabad', 9),
('Miraj Cinemas', 'Mumbai', 6),
('Carnival Cinemas', 'Pune', 5),
('Sathyam Cinemas', 'Chennai', 10),
('INOX GVK One', 'Hyderabad', 6),
('SPI Cinemas', 'Coimbatore', 4);

INSERT INTO Movies (title, genre, duration_minutes, rating) VALUES
('Inception', 'Sci-Fi', 148, 8.8),
('RRR', 'Action', 182, 8.0),
('Barbie', 'Comedy', 114, 7.2),
('Interstellar', 'Sci-Fi', 169, 8.6),
('Avengers: Endgame', 'Action', 181, 8.4),
('KGF Chapter 2', 'Action', 168, 8.3),
('Oppenheimer', 'Biography', 180, 8.7),
('The Dark Knight', 'Action', 152, 9.0),
('Frozen 2', 'Animation', 103, 6.9),
('Jawan', 'Thriller', 169, 7.5);

INSERT INTO Showtimes (theatre_id, movie_id, screen_no, show_time) VALUES
(1, 1, 3, '2025-08-28 18:30:00'),
(1, 2, 2, '2025-08-28 21:00:00'),
(2, 3, 1, '2025-08-28 19:00:00'),
(3, 4, 4, '2025-08-29 20:00:00'),
(4, 5, 1, '2025-08-29 17:30:00'),
(5, 6, 5, '2025-08-30 19:15:00'),
(6, 7, 2, '2025-08-30 21:45:00'),
(7, 8, 3, '2025-08-31 16:00:00'),
(8, 9, 6, '2025-08-31 14:00:00'),
(9, 10, 2, '2025-08-31 19:30:00');

INSERT INTO Bookings (show_id, customer_name, seats_booked) VALUES
(1, 'Praveen Kumar', 2),
(2, 'Ananya Sharma', 4),
(3, 'Rahul Verma', 3),
(4, 'Sneha Reddy', 5),
(5, 'Arjun Nair', 2),
(6, 'Meera Kapoor', 6),
(7, 'Siddharth Rao', 3),
(8, 'Kavya Iyer', 4),
(9, 'Rohan Gupta', 2),
(10, 'Divya Menon', 5);
............................................................................................
-- Add a new column for theatre contact number
ALTER TABLE Theatres 
ADD contact_no VARCHAR(15);

-- Modify total_screens to allow NULL values
ALTER TABLE Theatres 
MODIFY total_screens INT NULL;

-- Rename column location to city
ALTER TABLE Theatres 
CHANGE location city VARCHAR(100);

-- Drop the contact_no column if not needed
ALTER TABLE Theatres 
DROP COLUMN contact_no;

ALTER TABLE Theatres RENAME TO CinemaHalls;
............................................................................................
SELECT * 
FROM Films
WHERE genre = 'Action' AND rating > 8.0;

SELECT * 
FROM Films
WHERE genre = 'Comedy' OR genre = 'Sci-Fi';

SELECT * 
FROM Films
WHERE NOT genre = 'Action';

SELECT * 
FROM Films
WHERE movie_title LIKE 'I%';

SELECT movie_title, runtime
FROM Films
WHERE runtime > ANY (SELECT runtime FROM Films WHERE runtime < 120);

SELECT movie_title, runtime
FROM Films
WHERE runtime > ALL (SELECT runtime FROM Films WHERE genre = 'Comedy');

SELECT hall_name, city
FROM CinemaHalls c
WHERE EXISTS (SELECT 1 FROM Schedules s WHERE s.theatre_id = c.theatre_id);

SELECT movie_title, rating
FROM Films
ORDER BY rating ASC;

SELECT movie_title, rating
FROM Films
ORDER BY rating DESC;

SELECT genre, COUNT(*) AS total_movies
FROM Films
GROUP BY genre;
............................................................................................
DELETE FROM Reservations;

DROP TABLE Reservations;
............................................................................................
UPDATE Films
SET rating = 9.0
WHERE movie_id = 1;
............................................................................................
SELECT s.show_id, c.hall_name, f.movie_title, s.start_time
FROM Schedules s
INNER JOIN CinemaHalls c ON s.theatre_id = c.theatre_id
INNER JOIN Films f ON s.movie_id = f.movie_id;

SELECT c.hall_name, s.show_id, s.start_time
FROM CinemaHalls c
LEFT JOIN Schedules s ON c.theatre_id = s.theatre_id;

SELECT s.show_id, s.start_time, c.hall_name
FROM CinemaHalls c
RIGHT JOIN Schedules s ON c.theatre_id = s.theatre_id;

SELECT c.hall_name, s.show_id, s.start_time
FROM CinemaHalls c
LEFT JOIN Schedules s ON c.theatre_id = s.theatre_id
UNION
SELECT c.hall_name, s.show_id, s.start_time
FROM CinemaHalls c
RIGHT JOIN Schedules s ON c.theatre_id = s.theatre_id;
............................................................................................
DELIMITER //
CREATE PROCEDURE AddMovie(
    IN p_title VARCHAR(100),
    IN p_genre VARCHAR(50),
    IN p_runtime INT,
    IN p_rating DECIMAL(3,1)
)
BEGIN
    INSERT INTO Films (movie_title, genre, runtime, rating)
    VALUES (p_title, p_genre, p_runtime, p_rating);
END //
DELIMITER ;

-- Call it:
CALL AddMovie('Pushpa 2', 'Action', 180, 8.2);

DELIMITER //
CREATE PROCEDURE UpdateMovieRating(
    IN p_movie_id INT,
    IN p_new_rating DECIMAL(3,1)
)
BEGIN
    UPDATE Films
    SET rating = p_new_rating
    WHERE movie_id = p_movie_id;
END //
DELIMITER ;

-- Call it:
CALL UpdateMovieRating(1, 9.0);

DELIMITER //
CREATE PROCEDURE DeleteBooking(
    IN p_booking_id INT
)
BEGIN
    DELETE FROM Reservations
    WHERE booking_id = p_booking_id;
END //
DELIMITER ;

-- Call it:
CALL DeleteBooking(5);

DELIMITER //
CREATE PROCEDURE GetShowsByTheatre(
    IN p_theatre_id INT
)
BEGIN
    SELECT s.show_id, f.movie_title, s.start_time
    FROM Schedules s
    JOIN Films f ON s.movie_id = f.movie_id
    WHERE s.theatre_id = p_theatre_id;
END //
DELIMITER ;

-- Call it:
CALL GetShowsByTheatre(1);
............................................................................................
-- Create audit table
CREATE TABLE Booking_Audit (
    audit_id INT AUTO_INCREMENT PRIMARY KEY,
    booking_id INT,
    action VARCHAR(20),
    action_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Trigger
DELIMITER //
CREATE TRIGGER after_booking_insert
AFTER INSERT ON Reservations
FOR EACH ROW
BEGIN
    INSERT INTO Booking_Audit (booking_id, action)
    VALUES (NEW.booking_id, 'INSERT');
END //
DELIMITER ;


-- Create log table
CREATE TABLE Movie_Rating_Log (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    movie_id INT,
    old_rating DECIMAL(3,1),
    new_rating DECIMAL(3,1),
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Trigger
DELIMITER //
CREATE TRIGGER after_movie_update
AFTER UPDATE ON Films
FOR EACH ROW
BEGIN
    INSERT INTO Movie_Rating_Log (movie_id, old_rating, new_rating)
    VALUES (OLD.movie_id, OLD.rating, NEW.rating);
END //
DELIMITER ;


DELIMITER //
CREATE TRIGGER after_booking_delete
AFTER DELETE ON Reservations
FOR EACH ROW
BEGIN
    INSERT INTO Booking_Audit (booking_id, action)
    VALUES (OLD.booking_id, 'DELETE');
END //
DELIMITER ;
............................................................................................

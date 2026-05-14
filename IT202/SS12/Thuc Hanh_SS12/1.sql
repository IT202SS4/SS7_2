CREATE DATABASE SocialNetwork;
USE SocialNetwork;

CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE posts (
    post_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    content TEXT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    is_deleted BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

CREATE TABLE comments (
    comment_id INT AUTO_INCREMENT PRIMARY KEY,
    post_id INT,
    user_id INT,
    content TEXT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (post_id) REFERENCES posts(post_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

CREATE TABLE likes (
    user_id INT,
    post_id INT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id, post_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (post_id) REFERENCES posts(post_id) ON DELETE CASCADE
);

CREATE TABLE friends (
    user_id INT,
    friend_id INT,
    status VARCHAR(20) NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id, friend_id),
    CHECK (user_id != friend_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (friend_id) REFERENCES users(user_id) ON DELETE CASCADE
);

CREATE INDEX idx_posts_created_at ON posts(created_at);

CREATE VIEW view_user_info AS
SELECT user_id, username, email, created_at
FROM users;

CREATE VIEW view_post_statistics AS
SELECT
    p.post_id,
    p.content,
    u.username,
    COUNT(DISTINCT l.user_id) AS total_likes,
    COUNT(DISTINCT c.comment_id) AS total_comments,
    p.created_at
FROM posts p
JOIN users u ON p.user_id = u.user_id
LEFT JOIN likes l ON p.post_id = l.post_id
LEFT JOIN comments c ON p.post_id = c.post_id
WHERE p.is_deleted = FALSE
GROUP BY p.post_id, p.content, u.username, p.created_at;

DELIMITER $$

CREATE PROCEDURE sp_add_user(
    IN p_username VARCHAR(50),
    IN p_password VARCHAR(255),
    IN p_email VARCHAR(100)
)
BEGIN
    DECLARE cnt INT;

    SELECT COUNT(*) INTO cnt
    FROM users
    WHERE email = p_email;

    IF cnt > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Email đã được sử dụng';
    ELSE
        INSERT INTO users(username, password, email)
        VALUES(p_username, p_password, p_email);
    END IF;
END $$

CREATE PROCEDURE sp_create_post(
    IN p_user_id INT,
    IN p_content TEXT,
    OUT p_new_post_id INT
)
BEGIN
    INSERT INTO posts(user_id, content)
    VALUES(p_user_id, p_content);

    SET p_new_post_id = LAST_INSERT_ID();
END $$

CREATE PROCEDURE sp_get_friends(
    IN p_user_id INT,
    IN p_limit INT,
    IN p_offset INT
)
BEGIN
    SELECT u.user_id, u.username, u.email
    FROM friends f
    JOIN users u ON f.friend_id = u.user_id
    WHERE f.user_id = p_user_id
      AND f.status = 'accepted'
    LIMIT p_limit OFFSET p_offset;
END $$

DELIMITER ;

INSERT INTO users(username, password, email)
VALUES
('alice', '123', 'alice@gmail.com'),
('bob', '123', 'bob@gmail.com'),
('charlie', '123', 'charlie@gmail.com');

INSERT INTO posts(user_id, content)
VALUES
(1, 'Post from Alice'),
(2, 'Post from Bob'),
(3, 'Post from Charlie');

INSERT INTO likes(user_id, post_id)
VALUES
(2, 1),
(3, 1),
(1, 2);

INSERT INTO comments(user_id, post_id, content)
VALUES
(2, 1, 'Nice post'),
(3, 1, 'Good'),
(1, 2, 'Great');

INSERT INTO friends(user_id, friend_id, status)
VALUES
(1, 2, 'accepted'),
(1, 3, 'accepted'),
(2, 3, 'accepted');
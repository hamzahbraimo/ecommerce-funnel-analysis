# category, brand, price index
CREATE INDEX idx_cbp
ON events(category, brand, price);

# user_id, user_session, event_time index
CREATE INDEX idx_ust
ON events(user_id, user_session, event_time);

# user_id, event_time, category index
CREATE INDEX idx_utc
ON events(user_id, event_time, category);

# user_id, price index
CREATE INDEX idx_up
ON events(user_id, price);

# category, brand index
CREATE INDEX idx_cb
ON events(category, brand);

# event_time, event_type index
CREATE INDEX idx_tt
ON events(event_time, event_type);
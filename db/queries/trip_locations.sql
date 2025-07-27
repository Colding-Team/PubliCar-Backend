-- name: CreateTripLocation :one
INSERT INTO trip_locations (trip_id, lat, lng, timestamp)
VALUES ($1, $2, $3, $4)
RETURNING *;

-- name: GetTripLocationByID :one
SELECT * FROM trip_locations
WHERE id = $1;

-- name: ListTripLocationsByTripID :many
SELECT * FROM trip_locations
WHERE trip_id = $1
ORDER BY timestamp ASC;

-- name: ListTripLocationsByTripIDWithPagination :many
SELECT * FROM trip_locations
WHERE trip_id = $1
ORDER BY timestamp ASC
LIMIT $2 OFFSET $3;

-- name: DeleteTripLocation :exec
DELETE FROM trip_locations
WHERE id = $1;

-- name: DeleteTripLocationsByTripID :exec
DELETE FROM trip_locations
WHERE trip_id = $1;


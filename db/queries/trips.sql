-- name: CreateTrip :one
INSERT INTO trips (
driver_id, company_id, start_time, start_photo_url
)
VALUES ($1, $2, $3, $4)
RETURNING *;

-- name: CompleteTrip :exec
UPDATE trips
SET
end_time = $2,
end_photo_url = $3,
travelled_meters = $4,
completed_at = $5
WHERE id = $1;

-- name: GetTripByID :one
SELECT * FROM trips
WHERE id = $1;

-- name: ListTripsByDriver :many
SELECT * FROM trips
WHERE driver_id = $1
ORDER BY start_time DESC
LIMIT $2 OFFSET $3;

-- name: ListTripsByCompany :many
SELECT * FROM trips
WHERE company_id = $1
ORDER BY start_time DESC
LIMIT $2 OFFSET $3;

-- name: ListTripsByPeriod :many
SELECT * FROM trips
WHERE driver_id = $1
AND start_time >= $2
AND end_time <= $3
ORDER BY start_time DESC;

-- name: GetOngoingTripByDriver :one
SELECT * FROM trips
WHERE driver_id = $1
AND end_time IS NULL
ORDER BY start_time DESC
LIMIT 1;

-- name: TotalMetersByDriver :one
SELECT COALESCE(SUM(travelled_meters), 0) AS total_meters
FROM trips
WHERE driver_id = $1;

-- name: DeleteTrip :exec
DELETE FROM trips
WHERE id = $1;

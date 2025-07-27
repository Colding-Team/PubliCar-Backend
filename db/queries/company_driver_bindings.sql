-- name: CreateCompanyDriverBinding :one
INSERT INTO company_driver_bindings (company_id, driver_id, start_date, end_date)
VALUES ($1, $2, $3, $4)
RETURNING *;

-- name: GetBindingByID :one
SELECT * FROM company_driver_bindings
WHERE id = $1;

-- name: GetActiveBindingByDriverID :one
SELECT * FROM company_driver_bindings
WHERE driver_id = $1
  AND end_date IS NULL
ORDER BY start_date DESC
LIMIT 1;

-- name: GetAllBindingsByDriverID :many
SELECT * FROM company_driver_bindings
WHERE driver_id = $1
ORDER BY start_date DESC;

-- name: GetAllBindingsByCompanyID :many
SELECT * FROM company_driver_bindings
WHERE company_id = $1
ORDER BY start_date DESC;

-- name: ListBindingsPaginated :many
SELECT * FROM company_driver_bindings
ORDER BY created_at DESC
LIMIT $1 OFFSET $2;

-- name: ListActiveBindings :many
SELECT * FROM company_driver_bindings
WHERE end_date IS NULL
ORDER BY created_at DESC
LIMIT $1 OFFSET $2;

-- name: ListFinishedBindings :many
SELECT * FROM company_driver_bindings
WHERE end_date IS NOT NULL
ORDER BY end_date DESC
LIMIT $1 OFFSET $2;

-- name: EndBinding :exec
UPDATE company_driver_bindings
SET end_date = $2
WHERE id = $1;

-- name: DeleteBinding :exec
DELETE FROM company_driver_bindings
WHERE id = $1;

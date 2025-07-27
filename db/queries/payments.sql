-- name: CreatePayment :one
INSERT INTO payments (
  trip_id,
  driver_id,
  amount,
  status,
  paid_at
) VALUES (
  $1, $2, $3, $4, $5
)
RETURNING *;

-- name: GetPaymentByID :one
SELECT * FROM payments
WHERE id = $1;

-- name: ListPayments :many
SELECT * FROM payments
ORDER BY created_at DESC
LIMIT $1 OFFSET $2;

-- name: ListPaymentsByDriver :many
SELECT * FROM payments
WHERE driver_id = $1
ORDER BY created_at DESC
LIMIT $2 OFFSET $3;

-- name: ListPaymentsByTrip :many
SELECT * FROM payments
WHERE trip_id = $1;

-- name: UpdatePaymentStatus :exec
UPDATE payments
SET status = $2, paid_at = $3
WHERE id = $1;

-- name: DeletePayment :exec
DELETE FROM payments
WHERE id = $1;

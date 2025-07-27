-- name: CreateCompany :one
INSERT INTO companies (name, cnpj, contact_email)
VALUES ($1, $2, $3)
RETURNING *;

-- name: GetCompanyByID :one
SELECT * FROM companies
WHERE id = $1;

-- name: GetCompanyByCNPJ :one
SELECT * FROM companies
WHERE cnpj = $1;

-- name: ListCompanies :many
SELECT * FROM companies
ORDER BY created_at DESC;

-- name: ListCompaniesPaginated :many
SELECT * FROM companies
ORDER BY created_at DESC
LIMIT $1 OFFSET $2;

-- name: SearchCompaniesByName :many
SELECT * FROM companies
WHERE name ILIKE '%' || $1 || '%'
ORDER BY created_at DESC;

-- name: UpdateCompany :exec
UPDATE companies
SET name = $2,
    cnpj = $3,
    contact_email = $4
WHERE id = $1;

-- name: DeleteCompany :exec
DELETE FROM companies
WHERE id = $1;

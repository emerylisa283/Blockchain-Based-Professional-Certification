;; Certification Body Verification Contract
;; This contract validates legitimate credentialing organizations

;; Define data maps
(define-map certification-bodies principal
  {
    name: (string-utf8 100),
    website: (string-utf8 100),
    verified: bool,
    creation-time: uint
  }
)

;; Define data variables
(define-data-var admin principal tx-sender)

;; Error codes
(define-constant ERR_UNAUTHORIZED u1)
(define-constant ERR_ALREADY_REGISTERED u2)
(define-constant ERR_NOT_FOUND u3)

;; Read-only functions
(define-read-only (get-certification-body (body-id principal))
  (map-get? certification-bodies body-id)
)

(define-read-only (is-admin)
  (is-eq tx-sender (var-get admin))
)

;; Public functions
(define-public (register-certification-body (name (string-utf8 100)) (website (string-utf8 100)))
  (let ((existing-entry (map-get? certification-bodies tx-sender)))
    (asserts! (is-none existing-entry) (err ERR_ALREADY_REGISTERED))

    (map-set certification-bodies tx-sender
      {
        name: name,
        website: website,
        verified: false,
        creation-time: block-height
      }
    )
    (ok true)
  )
)

(define-public (verify-certification-body (body-id principal))
  (begin
    (asserts! (is-admin) (err ERR_UNAUTHORIZED))
    (asserts! (is-some (map-get? certification-bodies body-id)) (err ERR_NOT_FOUND))

    (map-set certification-bodies body-id
      (merge (unwrap-panic (map-get? certification-bodies body-id))
        { verified: true }
      )
    )
    (ok true)
  )
)

(define-public (transfer-admin (new-admin principal))
  (begin
    (asserts! (is-admin) (err ERR_UNAUTHORIZED))
    (var-set admin new-admin)
    (ok true)
  )
)

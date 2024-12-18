;; Digital Services Marketplace Contract

(define-data-var next-service-id uint u1)
(define-data-var next-milestone-id uint u1)
(define-data-var next-dispute-id uint u1)

(define-map services
  { service-id: uint }
  {
    provider: principal,
    client: principal,
    description: (string-utf8 500),
    total-amount: uint,
    status: (string-ascii 20)
  }
)

(define-map milestones
  { milestone-id: uint }
  {
    service-id: uint,
    amount: uint,
    description: (string-utf8 500),
    status: (string-ascii 20)
  }
)

(define-map disputes
  { dispute-id: uint }
  {
    service-id: uint,
    description: (string-utf8 500),
    status: (string-ascii 20)
  }
)

(define-map user-reputation
  { user: principal }
  { score: int }
)

(define-public (create-service (description (string-utf8 500)) (total-amount uint))
  (let
    (
      (service-id (var-get next-service-id))
    )
    (map-set services
      { service-id: service-id }
      {
        provider: tx-sender,
        client: tx-sender,
        description: description,
        total-amount: total-amount,
        status: "open"
      }
    )
    (var-set next-service-id (+ service-id u1))
    (ok service-id)
  )
)

(define-public (accept-service (service-id uint))
  (let
    (
      (service (unwrap! (map-get? services { service-id: service-id }) (err u404)))
    )
    (asserts! (is-eq (get status service) "open") (err u403))
    (asserts! (not (is-eq tx-sender (get provider service))) (err u403))
    (try! (stx-transfer? (get total-amount service) tx-sender (as-contract tx-sender)))
    (map-set services
      { service-id: service-id }
      (merge service { client: tx-sender, status: "in-progress" })
    )
    (ok true)
  )
)

(define-public (add-milestone (service-id uint) (amount uint) (description (string-utf8 500)))
  (let
    (
      (service (unwrap! (map-get? services { service-id: service-id }) (err u404)))
      (milestone-id (var-get next-milestone-id))
    )
    (asserts! (is-eq tx-sender (get provider service)) (err u403))
    (asserts! (is-eq (get status service) "in-progress") (err u403))
    (map-set milestones
      { milestone-id: milestone-id }
      {
        service-id: service-id,
        amount: amount,
        description: description,
        status: "pending"
      }
    )
    (var-set next-milestone-id (+ milestone-id u1))
    (ok milestone-id)
  )
)

(define-public (complete-milestone (milestone-id uint))
  (let
    (
      (milestone (unwrap! (map-get? milestones { milestone-id: milestone-id }) (err u404)))
      (service (unwrap! (map-get? services { service-id: (get service-id milestone) }) (err u404)))
    )
    (asserts! (is-eq tx-sender (get client service)) (err u403))
    (asserts! (is-eq (get status milestone) "pending") (err u403))
    (try! (as-contract (stx-transfer? (get amount milestone) tx-sender (get provider service))))
    (map-set milestones
      { milestone-id: milestone-id }
      (merge milestone { status: "completed" })
    )
    (ok true)
  )
)

(define-public (raise-dispute (service-id uint) (description (string-utf8 500)))
  (let
    (
      (service (unwrap! (map-get? services { service-id: service-id }) (err u404)))
      (dispute-id (var-get next-dispute-id))
    )
    (asserts! (or (is-eq tx-sender (get provider service)) (is-eq tx-sender (get client service))) (err u403))
    (asserts! (is-eq (get status service) "in-progress") (err u403))
    (map-set disputes
      { dispute-id: dispute-id }
      {
        service-id: service-id,
        description: description,
        status: "open"
      }
    )
    (map-set services
      { service-id: service-id }
      (merge service { status: "disputed" })
    )
    (var-set next-dispute-id (+ dispute-id u1))
    (ok dispute-id)
  )
)

(define-public (resolve-dispute (dispute-id uint) (resolution (string-ascii 20)))
  (let
    (
      (dispute (unwrap! (map-get? disputes { dispute-id: dispute-id }) (err u404)))
      (service (unwrap! (map-get? services { service-id: (get service-id dispute) }) (err u404)))
    )
    (asserts! (is-eq tx-sender (as-contract tx-sender)) (err u403))
    (asserts! (is-eq (get status dispute) "open") (err u403))
    (map-set disputes
      { dispute-id: dispute-id }
      (merge dispute { status: "resolved" })
    )
    (map-set services
      { service-id: (get service-id dispute) }
      (merge service { status: resolution })
    )
    (ok true)
  )
)

(define-public (update-reputation (user principal) (score int))
  (let
    (
      (current-score (default-to 0 (get score (map-get? user-reputation { user: user }))))
    )
    (asserts! (is-eq tx-sender (as-contract tx-sender)) (err u403))
    (map-set user-reputation
      { user: user }
      { score: (+ current-score score) }
    )
    (ok true)
  )
)

(define-read-only (get-service (service-id uint))
  (ok (unwrap! (map-get? services { service-id: service-id }) (err u404)))
)

(define-read-only (get-milestone (milestone-id uint))
  (ok (unwrap! (map-get? milestones { milestone-id: milestone-id }) (err u404)))
)

(define-read-only (get-dispute (dispute-id uint))
  (ok (unwrap! (map-get? disputes { dispute-id: dispute-id }) (err u404)))
)

(define-read-only (get-user-reputation (user principal))
  (ok (default-to { score: 0 } (map-get? user-reputation { user: user })))
)


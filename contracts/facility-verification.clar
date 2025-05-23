;; Facility Verification Contract
;; Validates production sites and their credentials

(define-data-var admin principal tx-sender)

;; Data structure for facilities
(define-map facilities
  { facility-id: (string-ascii 32) }
  {
    owner: principal,
    name: (string-ascii 100),
    location: (string-ascii 100),
    certification-status: bool,
    certification-date: uint,
    last-audit-date: uint
  }
)

;; Public function to register a new facility
(define-public (register-facility
    (facility-id (string-ascii 32))
    (name (string-ascii 100))
    (location (string-ascii 100)))
  (let ((caller tx-sender))
    (if (map-insert facilities
        { facility-id: facility-id }
        {
          owner: caller,
          name: name,
          location: location,
          certification-status: false,
          certification-date: u0,
          last-audit-date: u0
        })
      (ok true)
      (err u1))))

;; Admin function to certify a facility
(define-public (certify-facility
    (facility-id (string-ascii 32))
    (certification-status bool))
  (let ((caller tx-sender))
    (if (is-eq caller (var-get admin))
      (match (map-get? facilities { facility-id: facility-id })
        facility (begin
          (map-set facilities
            { facility-id: facility-id }
            (merge facility {
              certification-status: certification-status,
              certification-date: block-height
            }))
          (ok true))
        (err u2))
      (err u3))))

;; Public function to update audit date
(define-public (update-audit
    (facility-id (string-ascii 32)))
  (let ((caller tx-sender))
    (match (map-get? facilities { facility-id: facility-id })
      facility (if (is-eq caller (get owner facility))
        (begin
          (map-set facilities
            { facility-id: facility-id }
            (merge facility {
              last-audit-date: block-height
            }))
          (ok true))
        (err u4))
      (err u5))))

;; Read-only function to check if a facility is certified
(define-read-only (is-certified (facility-id (string-ascii 32)))
  (match (map-get? facilities { facility-id: facility-id })
    facility (get certification-status facility)
    false))

;; Read-only function to get facility details
(define-read-only (get-facility (facility-id (string-ascii 32)))
  (map-get? facilities { facility-id: facility-id }))

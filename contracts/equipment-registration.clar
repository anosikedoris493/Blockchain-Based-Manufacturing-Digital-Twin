;; Equipment Registration Contract
;; Records manufacturing assets and their specifications

(define-data-var admin principal tx-sender)

;; Data structure for equipment
(define-map equipment
  { equipment-id: (string-ascii 32) }
  {
    facility-id: (string-ascii 32),
    owner: principal,
    name: (string-ascii 100),
    equipment-type: (string-ascii 50),
    manufacturer: (string-ascii 100),
    installation-date: uint,
    last-maintenance-date: uint,
    operational-status: bool
  }
)

;; Public function to register new equipment
(define-public (register-equipment
    (equipment-id (string-ascii 32))
    (facility-id (string-ascii 32))
    (name (string-ascii 100))
    (equipment-type (string-ascii 50))
    (manufacturer (string-ascii 100)))
  (let ((caller tx-sender))
    (if (map-insert equipment
        { equipment-id: equipment-id }
        {
          facility-id: facility-id,
          owner: caller,
          name: name,
          equipment-type: equipment-type,
          manufacturer: manufacturer,
          installation-date: block-height,
          last-maintenance-date: block-height,
          operational-status: true
        })
      (ok true)
      (err u1))))

;; Public function to update equipment maintenance
(define-public (update-maintenance
    (equipment-id (string-ascii 32)))
  (let ((caller tx-sender))
    (match (map-get? equipment { equipment-id: equipment-id })
      equip (if (is-eq caller (get owner equip))
        (begin
          (map-set equipment
            { equipment-id: equipment-id }
            (merge equip {
              last-maintenance-date: block-height
            }))
          (ok true))
        (err u2))
      (err u3))))

;; Public function to update operational status
(define-public (update-operational-status
    (equipment-id (string-ascii 32))
    (status bool))
  (let ((caller tx-sender))
    (match (map-get? equipment { equipment-id: equipment-id })
      equip (if (is-eq caller (get owner equip))
        (begin
          (map-set equipment
            { equipment-id: equipment-id }
            (merge equip {
              operational-status: status
            }))
          (ok true))
        (err u4))
      (err u5))))

;; Read-only function to get equipment details
(define-read-only (get-equipment (equipment-id (string-ascii 32)))
  (map-get? equipment { equipment-id: equipment-id }))

;; Read-only function to check if equipment is operational
(define-read-only (is-operational (equipment-id (string-ascii 32)))
  (match (map-get? equipment { equipment-id: equipment-id })
    equip (get operational-status equip)
    false))

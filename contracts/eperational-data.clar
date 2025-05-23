;; Operational Data Contract
;; Tracks real-time metrics from manufacturing equipment

;; Data structure for operational data entries
(define-map operational-data
  {
    equipment-id: (string-ascii 32),
    timestamp: uint
  }
  {
    temperature: int,
    pressure: int,
    vibration: int,
    power-consumption: uint,
    production-rate: uint,
    quality-score: uint,
    operator: principal
  }
)

;; Counter for total data points
(define-data-var data-point-counter uint u0)

;; Public function to record operational data
(define-public (record-data
    (equipment-id (string-ascii 32))
    (temperature int)
    (pressure int)
    (vibration int)
    (power-consumption uint)
    (production-rate uint)
    (quality-score uint))
  (let ((caller tx-sender)
        (current-time block-height))
    (if (map-insert operational-data
        {
          equipment-id: equipment-id,
          timestamp: current-time
        }
        {
          temperature: temperature,
          pressure: pressure,
          vibration: vibration,
          power-consumption: power-consumption,
          production-rate: production-rate,
          quality-score: quality-score,
          operator: caller
        })
      (begin
        (var-set data-point-counter (+ (var-get data-point-counter) u1))
        (ok true))
      (err u1))))

;; Read-only function to get operational data
(define-read-only (get-data (equipment-id (string-ascii 32)) (timestamp uint))
  (map-get? operational-data { equipment-id: equipment-id, timestamp: timestamp }))

;; Read-only function to get total data points recorded
(define-read-only (get-data-point-count)
  (var-get data-point-counter))

;; Read-only function to check if data exists for a specific time
(define-read-only (data-exists (equipment-id (string-ascii 32)) (timestamp uint))
  (is-some (map-get? operational-data { equipment-id: equipment-id, timestamp: timestamp })))

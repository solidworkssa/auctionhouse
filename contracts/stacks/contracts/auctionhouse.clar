;; ────────────────────────────────────────
;; AuctionHouse v1.0.0
;; Author: solidworkssa
;; License: MIT
;; ────────────────────────────────────────

(define-constant VERSION "1.0.0")

;; Error codes
(define-constant ERR-NOT-AUTHORIZED (err u401))
(define-constant ERR-NOT-FOUND (err u404))
(define-constant ERR-ALREADY-EXISTS (err u409))
(define-constant ERR-INVALID-INPUT (err u422))

;; AuctionHouse Clarity Contract
;; Simple auction contract with bidding.


(define-data-var highest-bid uint u0)
(define-data-var highest-bidder (optional principal) none)
(define-data-var end-block uint (+ block-height u1000))
(define-constant beneficiary contract-caller)

(define-public (bid (amount uint))
    (begin
        (asserts! (< block-height (var-get end-block)) (err u100))
        (asserts! (> amount (var-get highest-bid)) (err u101))
        
        (match (var-get highest-bidder)
            bidder (try! (as-contract (stx-transfer? (var-get highest-bid) contract-caller bidder)))
            true
        )
        
        (try! (stx-transfer? amount contract-caller (as-contract contract-caller)))
        (var-set highest-bid amount)
        (var-set highest-bidder (some contract-caller))
        (ok true)
    )
)

(define-public (end-auction)
    (begin
        (asserts! (>= block-height (var-get end-block)) (err u100))
        (try! (as-contract (stx-transfer? (var-get highest-bid) contract-caller beneficiary)))
        (ok true)
    )
)


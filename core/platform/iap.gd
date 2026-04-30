class_name PlatformIAP
extends RefCounted

# In-app purchase interface stub. The real bodies (Apple App
# Store / Google Play / Steam DLC) wire up in the final 4 weeks
# before submission per docs/design/monetization.md. This file
# nails down the surface shape *now* so the rest of the codebase
# can call it without churn later.
#
# The launch contract from CLAUDE.md:
#   * Cosmetic IAP only — no pay-to-win, no gameplay items.
#   * Server-side receipt validation before unlocking anything.
#   * No interstitials, no nag screens, no gift-offer popups.
#
# Until launch the methods are no-ops. is_available() always
# returns false so the cosmetics shop UI stays dark in dev
# builds — flip the flag in a subclass when wiring real backends.

signal product_purchased(product_id: StringName)
signal restore_completed(product_ids: Array[StringName])
signal purchase_failed(product_id: StringName, reason: String)

var _initialized: bool = false

func initialize() -> void:
	# Real implementation: kick off store-SDK init (StoreKit /
	# BillingClient / SteamUser auth ticket). Stub records that
	# init was called so smoke tests can verify call ordering.
	_initialized = true

func is_available() -> bool:
	return false  # always false in dev; subclass overrides at launch

func is_initialized() -> bool:
	return _initialized

# Returns the catalog the storefront should display. Real
# implementation queries the store; stub returns an empty list.
func fetch_products() -> Array[Dictionary]:
	return []

# Real implementation: trigger a store-side purchase flow and
# wait for the platform callback. Stub is a no-op that emits
# purchase_failed so callers can verify their failure path.
func purchase(product_id: StringName) -> void:
	purchase_failed.emit(product_id, "iap_stub_unavailable")

# Real implementation: queries the platform for previous
# purchases and re-grants them. Stub emits restore_completed
# with an empty list.
func restore_purchases() -> void:
	var empty: Array[StringName] = []
	restore_completed.emit(empty)

# Real implementation: server-side receipt validation against
# Apple's verifyReceipt / Play Developer API / Steam
# ISteamMicroTxn. Stub returns false to keep cosmetics locked
# until a real backend is wired up.
func validate_receipt(receipt_payload: String) -> bool:
	return false

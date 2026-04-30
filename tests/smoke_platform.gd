extends SceneTree

# Headless smoke test for the PlatformIAP and PlatformAds stubs.
# Verifies the no-op contract: methods don't crash, default
# states are correct, and the failure-path signals fire as
# documented. This locks in the interface shape so downstream
# feature code can depend on it.
#
# Run: godot --headless --script res://tests/smoke_platform.gd

var _iap_failure_seen: bool = false
var _iap_failure_reason: String = ""
var _iap_restore_seen: bool = false
var _iap_restore_count: int = -1
var _ads_failure_seen: bool = false
var _ads_failure_reason: String = ""

func _initialize() -> void:
	_test_iap()
	_test_ads()
	print("smoke_platform: ok. IAP and Ads stubs honor their contracts.")
	quit(0)

func _test_iap() -> void:
	var iap: PlatformIAP = PlatformIAP.new()

	if iap.is_initialized():
		_fail("IAP should not be initialized before initialize()")
		return
	if iap.is_available():
		_fail("IAP should be unavailable in dev builds")
		return

	iap.initialize()
	if not iap.is_initialized():
		_fail("IAP should be initialized after initialize()")
		return
	if iap.is_available():
		_fail("IAP should still be unavailable post-init in stubs")
		return

	var products: Array[Dictionary] = iap.fetch_products()
	if not products.is_empty():
		_fail("IAP fetch_products should return [] in stub, got %d entries" % products.size())
		return

	iap.purchase_failed.connect(_on_iap_failed)
	iap.purchase(&"test_product")
	if not _iap_failure_seen:
		_fail("IAP purchase should emit purchase_failed in stub")
		return
	if _iap_failure_reason != "iap_stub_unavailable":
		_fail("IAP purchase reason mismatch: %s" % _iap_failure_reason)
		return

	iap.restore_completed.connect(_on_iap_restore)
	iap.restore_purchases()
	if not _iap_restore_seen:
		_fail("IAP restore_purchases should emit restore_completed")
		return
	if _iap_restore_count != 0:
		_fail("IAP restore should be empty in stub, got %d" % _iap_restore_count)
		return

	if iap.validate_receipt("any-payload"):
		_fail("IAP validate_receipt should return false in stub")
		return

func _test_ads() -> void:
	var ads: PlatformAds = PlatformAds.new()

	if ads.is_initialized():
		_fail("Ads should not be initialized before initialize()")
		return
	if ads.is_available():
		_fail("Ads should be unavailable in dev builds")
		return
	if ads.is_personalized():
		_fail("Ads default should be non-personalized")
		return

	ads.initialize(true)
	if not ads.is_initialized():
		_fail("Ads should be initialized after initialize()")
		return
	if not ads.is_personalized():
		_fail("Ads should reflect personalized=true after explicit consent")
		return
	if ads.is_available():
		_fail("Ads should still be unavailable post-init in stub")
		return

	# load_rewarded is a documented no-op; calling it must not crash.
	ads.load_rewarded()

	ads.ad_failed.connect(_on_ad_failed)
	ads.show_rewarded(1)
	if not _ads_failure_seen:
		_fail("Ads show_rewarded should emit ad_failed in stub")
		return
	if _ads_failure_reason != "ads_stub_unavailable":
		_fail("Ads failure reason mismatch: %s" % _ads_failure_reason)
		return

func _on_iap_failed(_pid: StringName, reason: String) -> void:
	_iap_failure_seen = true
	_iap_failure_reason = reason

func _on_iap_restore(product_ids: Array[StringName]) -> void:
	_iap_restore_seen = true
	_iap_restore_count = product_ids.size()

func _on_ad_failed(reason: String) -> void:
	_ads_failure_seen = true
	_ads_failure_reason = reason

func _fail(msg: String) -> void:
	push_error("smoke_platform: %s" % msg)
	quit(1)

class_name PlatformAds
extends RefCounted

# Rewarded-ad interface stub. Real bodies (Google AdMob /
# AppLovin / Unity Ads, on Tier-2 free mobile only) wire up if
# and when the free tier is greenlit per
# docs/design/monetization.md. This file pins the surface shape
# so feature code can depend on it without churn.
#
# The locked contract from CLAUDE.md + monetization.md:
#   * Rewarded ads ONLY. No interstitials. No banners. No
#     popups on app launch, between battles, or on death.
#   * One ad per 24 hours, optional, off the hub screen.
#   * Privacy: respect ATT (iOS), DMA (EU); default to
#     non-personalized when the user opts out.
#
# Until launch (and only on the free tier when launched) all
# methods are no-ops. is_available() always returns false so
# the hub button stays disabled in dev builds.

signal reward_earned(amount: int)
signal ad_failed(reason: String)
signal ad_dismissed

var _initialized: bool = false
var _personalized: bool = false  # honor user opt-out by default

func initialize(personalized_consent: bool = false) -> void:
	# Real impl: init the ad SDK with consent flag. Stub records
	# state so smoke tests can verify call ordering.
	_initialized = true
	_personalized = personalized_consent

func is_available() -> bool:
	return false  # always false in dev / non-free-tier builds

func is_initialized() -> bool:
	return _initialized

func is_personalized() -> bool:
	return _personalized

# Real impl: preload the next rewarded ad so it shows quickly.
# Stub is a no-op.
func load_rewarded() -> void:
	pass

# Real impl: present the rewarded ad UI; on completion emit
# reward_earned. Stub emits ad_failed so callers can verify the
# failure path.
func show_rewarded(reward_amount: int = 1) -> void:
	ad_failed.emit("ads_stub_unavailable")

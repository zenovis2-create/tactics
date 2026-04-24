class_name GutTest
extends Node

## Minimal local compatibility shim for headless parse checks when the GUT addon
## is not installed in this workspace. It provides the assertion methods used by
## tests/test_bond_service.gd without affecting runtime gameplay code.

func assert_eq(actual: Variant, expected: Variant, message: String = "") -> void:
	if actual != expected:
		push_error(_format_assertion_message("assert_eq", actual, expected, message))


func assert_true(value: bool, message: String = "") -> void:
	if not value:
		push_error(_format_assertion_message("assert_true", value, true, message))


func assert_false(value: bool, message: String = "") -> void:
	if value:
		push_error(_format_assertion_message("assert_false", value, false, message))


func _format_assertion_message(assertion: String, actual: Variant, expected: Variant, message: String) -> String:
	var suffix := ""
	if not message.is_empty():
		suffix = " — %s" % message
	return "%s failed: expected %s, got %s%s" % [assertion, str(expected), str(actual), suffix]

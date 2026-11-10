.PHONY: verify

verify:
	dart format --set-exit-if-changed lib test
	flutter analyze --no-fatal-infos
	flutter test

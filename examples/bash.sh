#!/usr/bin/env bash

set -euo pipefail

readonly APP_NAME="nightjungle"
readonly DEFAULT_ENV="dev"

print_usage() {
	cat <<'EOF'
Usage: ./bash.sh [env]

Examples:
  ./bash.sh dev
  ./bash.sh prod
EOF
}

resolve_env() {
	local input="${1:-$DEFAULT_ENV}"
	if [[ "$input" == "production" ]]; then
		echo "prod"
		return
	fi

	echo "$input"
}

main() {
	local env
	env="$(resolve_env "${1:-}")"

	if [[ "$env" != "dev" && "$env" != "prod" ]]; then
		echo "Unsupported env: $env" >&2
		print_usage
		exit 1
	fi

	for step in prepare lint test build; do
		printf '[%s] %s: %s\n' "$(date +%H:%M:%S)" "$APP_NAME" "$step"
	done

	case "$env" in
	dev)
		echo "Running in development mode"
		;;
	prod)
		echo "Running in production mode"
		;;
	esac
}

main "$@"

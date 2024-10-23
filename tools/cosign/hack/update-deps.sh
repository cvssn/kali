set -o errexit
set -o nounset
set -o pipefail

pushd $(dirname "$0")/..

go get ./...
go mod tidy
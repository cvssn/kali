package now

import (
	"fmt"
	"os"
	"strconv"
	"time"
)

// agora retorna source_date_epoch ou time.now()
func Now() (time.Time, error) {
	// nolint
	epoch := os.Getenv("SOURCE_DATE_EPOCH")

	if epoch == "" {
		return time.Now(), nil
	}

	seconds, err := strconv.ParseInt(epoch, 10, 64)

	if err != nil {
		return time.Now(), fmt.Errorf("source_date_epoch deve ser o número de segundos desde 1 de janeiro de 1970, 00:00 utc, recebido: %w", err)
	}

	return time.Unix(seconds, 0), nil
}
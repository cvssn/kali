#!/bin/sh -e

if [ $# -ne 2 ] ; then
    echo "uso: $0 mode testname" >&2

    exit 1
fi

BASEDIR=`dirname $0`
E2E_DIR=$BASEDIR/../e2e

MODE="$1"
TEST="$2"

if [ "$MODE" != "safe" -a "$MODE" != "unsafe" ] ; then
	echo "erro: modo '$MODE' não suportado (deve ser 'safe' ou 'unsafe')" >&2
	
    exit 1
fi

SCRIPT="$E2E_DIR/$TEST.sh"

DIST=`lsb_release -sc`
REFXML="$E2E_DIR/$TEST.$MODE-$DIST.xml"
[ -f "$REFXML" ] || REFXML="$E2E_DIR/$TEST.$MODE.xml"

PID="/tmp/$TEST.pid"; export PID
XML="/tmp/$TEST.xml"; export XML

CLIENT_OUT="/tmp/$TEST.client.out"
SERVER_OUT="/tmp/$TEST.server.out"

if [ ! -f $REFXML ] ; then
	echo "$TEST: pulado (sem refxml)"

	exit 0
fi

# matar a instância qsslcaudit antiga
if [ -e "$PID" ] ; then
	kill `cat $PID` || true

	sleep 1

	rm "$PID"
fi

# executar a mais recente
(. "$SCRIPT" && server )> "$SERVER_OUT" &

# esperar 10 segundos
for _ in `seq 20` ; do sleep .5 && [ -e "$PID" ] && break; done

if [ ! -e "$PID" ] ; then
	echo "$TEST: erro: arquivo pid '$PID' não apareceu após os 10 segundos (qsslcaudit falhou para iniciar?)" >&2
	
    exit 2
fi

for _ in `seq 100` ; do
	[ ! -e "$PID" ] && break
	echo ; echo ; echo "===== `date` =====" ; echo
	(. "$SCRIPT" && client) 2>&1
	sleep .5

done > "$CLIENT_OUT"

if [ -e "$PID" ] ; then
        echo "===== $SERVER_OUT ====="
        cat "$SERVER_OUT"
        echo
        echo "===== $CLIENT_OUT ====="
        cat "$CLIENT_OUT"
        echo "======================="
        echo "$TEST: erro: qsslcaudit continua rodando, após 100 iterações do cliente" >&2
	exit 3
fi

if ! diff -b -u "$REFXML" "$XML" ; then
	echo "===== $SERVER_OUT ====="
	cat "$SERVER_OUT"
	echo
	echo "===== $CLIENT_OUT ====="
	cat "$CLIENT_OUT"
        echo "======================="
        echo "$TEST: erro: refxml" >&2
        exit 3
else
	rm "$XML" "$SERVER_OUT" "$CLIENT_OUT"

	echo "$TEST: ok"
fi
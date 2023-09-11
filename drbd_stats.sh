#!/bin/bash

# drbd_stats.sh
# /usr/local/bin/drbd_stats.sh
# chmod +x /usr/local/bin/drbd_stats.sh

MINOR_NUM="$1"
METRIC="$2"

if [ -z "$MINOR_NUM" ] || [ -z "$METRIC" ]; then
    echo "Usage: $0 <MINOR_NUM> <METRIC>"
    exit 1
fi

DATA=$(awk -v minor="$MINOR_NUM" '$1 ~ "^\\s*"minor":" {getline; print $0}' /proc/drbd)
CONNECTION_DATA=$(awk -v minor="$MINOR_NUM" '$1 ~ "^\\s*"minor":" {print $0}' /proc/drbd)

function cs_mapping {
    local cs_value="$1"

    case "$cs_value" in
        "Connected")         echo 1 ;;  # A DRBD connection has been established, data mirroring is now active.
        "SyncSource")        echo 2 ;;  # Synchronization is currently running, with the local node being the source of synchronization.
        "SyncTarget")        echo 3 ;;  # Synchronization is currently running, with the local node being the target of synchronization.
        "VerifyS")           echo 4 ;;  # On-line device verification is currently running, with the local node being the source of verification.
        "VerifyT")           echo 5 ;;  # On-line device verification is currently running, with the local node being the target of verification.
        "WFReportParams")    echo 6 ;;  # TCP connection has been established, this node waits for the first network packet from the peer.
        "StartingSyncS")     echo 7 ;;  # Full synchronization, initiated by the administrator, is just starting. The local node will be the source.
        "StartingSyncT")     echo 8 ;;  # Full synchronization, initiated by the administrator, is just starting. The local node will be the target.
        "WFBitMapS")         echo 9 ;;  # Partial synchronization is just starting. The local node will be the source of synchronization.
        "WFBitMapT")         echo 10 ;; # Partial synchronization is just starting. The local node will be the target of synchronization.
        "WFSyncUUID")        echo 11 ;; # Synchronization is about to begin. Next possible states: SyncTarget or PausedSyncT.
        "PausedSyncS")       echo 12 ;; # The local node is the source of an ongoing synchronization, but synchronization is currently paused.
        "PausedSyncT")       echo 13 ;; # The local node is the target of an ongoing synchronization, but synchronization is currently paused.
        "StandAlone")        echo 14 ;; # No network configuration available. The resource has not yet been connected, or has been administratively disconnected.
        "Disconnecting")     echo 15 ;; # Temporary state during disconnection. The next state is StandAlone.
        "Unconnected")       echo 16 ;; # Temporary state, prior to a connection attempt. Possible next states: WFConnection and WFReportParams.
        "Timeout")           echo 17 ;; # Temporary state following a timeout in the communication with the peer. Next state: Unconnected.
        "BrokenPipe")        echo 18 ;; # Temporary state after the connection to the peer was lost. Next state: Unconnected.
        "NetworkFailure")    echo 19 ;; # Temporary state after the connection to the partner was lost. Next state: Unconnected.
        "ProtocolError")     echo 20 ;; # Temporary state after the connection to the partner was lost. Next state: Unconnected.
        "TearDown")          echo 21 ;; # Temporary state. The peer is closing the connection. Next state: Unconnected.
        "WFConnection")      echo 22 ;; # This node is waiting until the peer node becomes visible on the network.
        *)                   echo 0  ;; # Unknown status
    esac

}
function ro_mapping() {
    local ro_value="$1"

    case "$ro_value" in
        "Primary/Secondary") echo 1;;  # Primary and Secondary
        "Secondary/Primary") echo 2;;  # Secondary and Primary
        "Primary/Unknown") echo 3;;    # Primary and Unknown
        "Secondary/Unknown") echo 4;;  # Secondary and Unknown
        *) echo 0;;                   # Any other or unrecognized value
    esac
}
function ds_mapping() {
    local ds_value="$1"

    case "$ds_value" in
        "UpToDate/UpToDate") echo 1;;   # Both sides are up-to-date
        "UpToDate/DUnknown") echo 2;;   # Local up-to-date, remote unknown
        "DUnknown/UpToDate") echo 3;;   # Local unknown, remote up-to-date
        "Inconsistent/DUnknown") echo 4;; # Local inconsistent, remote unknown
        "DUnknown/Inconsistent") echo 5;; # Local unknown, remote inconsistent
        "Consistent/DUnknown") echo 6;; # Local consistent, remote unknown
        "Inconsistent/UpToDate") echo 7;; # Local inconsistent, remote consistent
        "UpToDate/Inconsistent") echo 8;; # Local consistent, remote inconsistent
        *) echo 0;;                     # Any other or unrecognized value
    esac
}


case $METRIC in
    "cs")
        CS_VALUE=$(echo "$CONNECTION_DATA" | awk -F'cs:' '{print $2}' | awk '{print $1}')
        echo $(cs_mapping "$CS_VALUE")
        ;;
    "ro")
        RO_VALUE=$(echo "$CONNECTION_DATA" | awk -F'ro:' '{print $2}' | awk '{print $1}')
        echo $(ro_mapping "$RO_VALUE")
        ;;
    "ds")
        DS_VALUE=$(echo "$CONNECTION_DATA" | awk -F'ds:' '{print $2}' | awk '{print $1}')
        echo $(ds_mapping "$DS_VALUE")
        ;;
    "ns") echo "$DATA" | awk -F'ns:' '{print $2}' | awk '{print $1}';;
    "nr") echo "$DATA" | awk -F'nr:' '{print $2}' | awk '{print $1}';;
    "dw") echo "$DATA" | awk -F'dw:' '{print $2}' | awk '{print $1}';;
    "dr") echo "$DATA" | awk -F'dr:' '{print $2}' | awk '{print $1}';;
    "al") echo "$DATA" | awk -F'al:' '{print $2}' | awk '{print $1}';;
    "bm") echo "$DATA" | awk -F'bm:' '{print $2}' | awk '{print $1}';;
    "lo") echo "$DATA" | awk -F'lo:' '{print $2}' | awk '{print $1}';;
    "pe") echo "$DATA" | awk -F'pe:' '{print $2}' | awk '{print $1}';;
    "ua") echo "$DATA" | awk -F'ua:' '{print $2}' | awk '{print $1}';;
    "ap") echo "$DATA" | awk -F'ap:' '{print $2}' | awk '{print $1}';;
    "ep") echo "$DATA" | awk -F'ep:' '{print $2}' | awk '{print $1}';;
    "wo") echo "$DATA" | awk -F'wo:' '{print $2}' | awk '{print $1}';;
    "oos") echo "$DATA" | awk -F'oos:' '{print $2}' | awk '{print $1}';;
    *) echo "Metric $METRIC not recognized"; exit 1;;
esac

exit 0

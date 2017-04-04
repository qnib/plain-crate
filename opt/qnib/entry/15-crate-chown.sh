#!/bin/bash

mkdir -p /data/{logs,blobs,data}
chown -R ${ENTRY_USER}: /data/{logs,blobs,data}

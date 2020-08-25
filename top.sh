#!/bin/bash

#1秒钟打印一次top输出(只打印内存占用前15位的进程)

SHELL_FOLDER=$(cd "$(dirname "$0")";pwd)
LOG_NAME="${SHELL_FOLDER}/top.log"

while true
do
    echo "$(date) start ..." >> ${LOG_NAME}
    top -b -o +%MEM -n 1 | head -n 22 >> ${LOG_NAME}
    echo "$(date) stop." >> ${LOG_NAME}
    sleep 1
done
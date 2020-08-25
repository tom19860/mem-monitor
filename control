#!/bin/bash

#控制top.sh的启停

SHELL_FOLDER=$(cd "$(dirname "$0")";pwd)
LOG_NAME="${SHELL_FOLDER}/top.log"
LOG_SIZE=100M
PROC_NAME="top.sh"
WAIT_TIME=60
cd ${SHELL_FOLDER}
chmod a+x ${PROC_NAME}

help(){
    echo "${0} <start|stop|restart|status>"
    exit 1
}

checkhealth(){
    ps -eo cmd |grep ${SHELL_FOLDER}/${PROC_NAME} |grep -v "grep" > /dev/null
    if [ $? -eq 0 ] ; then
        echo "${PROC_NAME} running"
        return 0
    fi
    echo "${PROC_NAME} not running"
    return 1
}

gen_logrotate(){
cat << EOF > ${SHELL_FOLDER}/logrotate.topsh
${LOG_NAME} {
size=${LOG_SIZE}
rotate 5
missingok
copytruncate
notifempty
}
EOF
}

install_logrotate_crontab(){
    echo "$(date) install crontab ..."
    gen_logrotate
    crontab -l > ${SHELL_FOLDER}/crontab.bak
    sed -i -e '/logrotate.topsh/d' ${SHELL_FOLDER}/crontab.bak
    echo "* * * * * /usr/sbin/logrotate ${SHELL_FOLDER}/logrotate.topsh > /dev/null 2>&1 &" >> ${SHELL_FOLDER}/crontab.bak
    crontab ${SHELL_FOLDER}/crontab.bak
    if [ $? -ne 0 ]
    then
        echo "$(date) install logrotate crontab failed!"
        exit 1
    else
        echo "$(date) install logrotate crontab success!"
    fi
    \rm -f ${SHELL_FOLDER}/crontab.bak
    #show result
    crontab -l
    return 0
}

uninstall_logrotate_crontab(){
    echo "$(date) uninstall crontab ..."
    crontab -l > ${SHELL_FOLDER}/crontab.bak
    sed -i -e '/logrotate.topsh/d' ${SHELL_FOLDER}/crontab.bak
    crontab ${SHELL_FOLDER}/crontab.bak
    if [ $? -ne 0 ]
    then
        echo "$(date) uninstall logrotate crontab failed!"
        exit 1
    else
        echo "$(date) uninstall logrotate crontab success!"
    fi
    \rm -f ${SHELL_FOLDER}/crontab.bak
    #show result
    crontab -l
    return 0
}

start(){
    checkhealth
    if [ $? -eq 0 ]; then
        echo "[WARN] $PROC_NAME is aleady running!"
        return 0
    fi
    install_logrotate_crontab
 
    nohup ${SHELL_FOLDER}/${PROC_NAME} >> /dev/null 2>&1 & 
 
    for i in $(seq $WAIT_TIME) ; do
        sleep 1
        checkhealth
        if [ $? -eq 0 ]; then
            echo "Start $PROC_NAME success"
            return 0
        fi
    done
    echo "[ERROR] Start $PROC_NAME failed"
    return 1
}

stop(){
    checkhealth
    if [ $? -ne 0 ] ; then
        echo "[WARN] $PROC_NAME is aleady exit, skip stop"
        return 0
    fi
    uninstall_logrotate_crontab

    pid=`ps -ef | grep "${SHELL_FOLDER}/${PROC_NAME}" | grep -v "grep" | awk -F' ' '{print $2}'`
    if [ -n "$pid" ]
    then
        kill -9 $pid
        if [ $? -ne 0 ]
        then
            echo "$(date) kill failed, may be ${PROC_NAME} isn't running"
            exit 1
        else
            echo "$(date) stop success"
            return 0
        fi
    else
        echo "$(date) get pid failed, may be ${PROC_NAME} isn't running"
        return 1
    fi
}

case "${1}" in
    start)
        start
        ;;
    stop)
        stop
        ;;
    status|health|checkhealth)
        checkhealth
        ;;
    restart)
        stop && start
        ;;
    *)
        help
        ;;
esac
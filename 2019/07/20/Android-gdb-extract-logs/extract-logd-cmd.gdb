#
# log_time
#

define log_time
    if $argc < 2
        help log_time
    else
        #eval "shell date -d @%d.%d '+%%Y-%%m-%%d %%H:%%M:%%S.%%N'",$arg0, $arg1
        eval "shell date -d @%d.%d '+%%Y-%%m-%%d %%H:%%M:%%S.%%N' >> time",$arg0, $arg1
    end
end

document log_time
	log_time tv_sec tv_nsec.
end

#
# log_msg
#

define log_msg
    if $argc < 4
        help log_msg
    else
        set $start_addr = $arg2
        set $end_addr = $start_addr + $arg3
        printf "%d %d ", $arg0, $arg1
        while $start_addr < $end_addr
            if *(char*)$start_addr > 31 && *(char*)$start_addr < 127
                printf "%c", *(char*)$start_addr
            else
                printf " "
            end
            set $start_addr = $start_addr + 1
        end
        printf "\n"
    end
end

document log_msg
	log_msg pid tid addr length.
end

#
# extract_a_log
#

define extract_a_log
    if $argc < 1
        help extract_a_log
    else
        set $elem = $arg0
        set $tv_sec = *&((LogBufferElement*)$elem).mRealTime.tv_sec
        set $tv_nsec = *&((LogBufferElement*)$elem).mRealTime.tv_nsec
        set $pid = *&((LogBufferElement*)$elem).mPid
        set $tid = *&((LogBufferElement*)$elem).mTid
        set $msg_addr = *&((LogBufferElement*)$elem).mMsg
        set $msg_len = *&((LogBufferElement*)$elem).mMsgLen
        log_time $tv_sec $tv_nsec
        log_msg $pid $tid $msg_addr $msg_len
    end
end

document extract_a_log
	extract_a_log 'address of LogBufferElement'.
end

#
# extract_all_logs
#
define extract_all_logs
    if $argc < 1
        help extract_all_logs
    else
        set $log_list = $arg0
        set $current = $log_list.__end_.__next_
        set $end = $log_list.__end_.__prev_.__next_
        while $current != $end
            set $log_elem = (('std::__1::__list_node<LogBufferElement*, void*>' *)$current).__value_
            extract_a_log $log_elem
            set $current = $current.__next_
        end

    end
end

document extract_all_logs
	extract_all_logs 'address of LogBufferElement std::list'.
end

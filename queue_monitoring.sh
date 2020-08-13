#!/bin/bash

############################################################
# Check out whether Sun Grid Engine is installed or not.
# Globals:
#   None
# Arguments:
#   None
# Outputs:
#   check_flag
############################################################
  function check_sungridengine() {
  check_flag=`which qhost >& /dev/null; echo $?` # is installed if output is 0
  echo ${check_flag}
}

############################################################
# Measure screen width.
# Globals:
#   None
# Arguments:
#   None
# Outputs:
#   check_flag
############################################################
  function check_screen() {
  screen_width=`echo -e "cols" | tput -S`
  echo ${screen_width}
}

###################################################################
# Determine the slot risk by counting how many slots are being used
# and assign the bar color:
# (low risk) green - yellow - red (high risk)
# Globals:
#   None
# Arguments:
#   slot_risk_ratio
# Outputs:
#   slot_bg_fg_color
###################################################################
  function slot_risk_measure() {
  slot_use_ratio=$1
  if [[ ${slot_use_ratio} -gt 70 ]]; then
    slot_bg_fg_color=31,41 # red (high risk)
    echo ${slot_bg_fg_color}
  elif [[ ${slot_use_ratio} -gt 30 ]]; then
    slot_bg_fg_color=33,43 # yellow
    echo ${slot_bg_fg_color}
  else
    slot_bg_fg_color=32,42 # green
    echo ${slot_bg_fg_color}
  fi 
}

########################################################################
# Determine the memory risk by checking how much memories are being used
# and assign the bar color:
# (low risk) green - yellow - red (high risk)
# Globals:
#   None
# Arguments:
#   mem_risk_ratio
# Outputs:
#   mem_bg_fg_color
########################################################################
  function mem_risk_measure() {
  mem_use_ratio=$1
  if [[ ${mem_use_ratio} -gt 70 ]]; then
    mem_bg_fg_color=31,41 # red (high risk)
    echo ${mem_bg_fg_color}
  elif [[ ${mem_use_ratio} -gt 30 ]]; then
    mem_bg_fg_color=33,43 # yellow
    echo ${mem_bg_fg_color}
  else
    mem_bg_fg_color=32,42 # green
    echo ${mem_bg_fg_color}
  fi
}

############################################################
# Determine the load average risk by checking load average
# according to internal criteria, and assign the bar color:
# (low risk) green - yellow - red (high risk)
# Globals:
#   None
# Arguments:
#   load_ave
# Outputs:
#   load_bg_fg_color
############################################################
  function load_risk_measure() {
  load_average=`echo $1 | cut -d'.' -f1`
  if [[ ${load_average} -gt 50 ]]; then
    load_bg_fg_color=31,41 # red (high risk)
    echo ${load_bg_fg_color}
  elif [[ ${load_average} -gt 20 ]]; then
    load_bg_fg_color=33,43 # cyan
    echo ${load_bg_fg_color}
  else
    load_bg_fg_color=32,42 # green
    echo ${load_bg_fg_color}
  fi
}

##############################################
# Check all queue (and node) status
# and make it easy to figure out at a glance.
# Globals:
#   line_number
# Arguments:
#   None
# Outputs:
#   print out queue status
##############################################
  function analysis_queue() {
  full_width=$(check_screen)
  wide_flag=0
  if [[ ${full_width} -gt 202 ]];then # wide mode is on when the screen width is greater than 202
    wide_flag=1 
  elif [[ ${full_width} -lt 93 ]];then # minimum screen width is equal to 93
    printf '\n\tCurrent screen width is '${full_width}','
    printf '\n\tand that is under minimum size(93).'
    printf '\n\tRecommended value is over 202.'
    printf '\n\tYou need to increase it.\n\n'
    exit
  fi

  half_screen_width=`echo "${full_width}" / 2 | bc`
  if [[ ${wide_flag} -eq 1 ]];then # setting different column width by using which screen mode
    col_1=`echo ${half_screen_width} / 7 | bc`
    col_2=`echo ${half_screen_width} / 12 | bc`
    col_3=`echo ${half_screen_width} / 8 \* 5 | bc`
    col_4=`echo ${half_screen_width} / 16 \* 3 | bc`
  else
    col_1=`echo ${half_screen_width} / 5 | bc`
    col_2=`echo ${half_screen_width} / 10 | bc`
    col_3=`echo ${half_screen_width} / 8 \* 5 | bc`
    col_4=`echo ${half_screen_width} / 16 \* 7 | bc`
  fi

  line_number=`qhost -q | sed '/-\+-/d' | sed '/HOSTNAME\|global/d' | wc -l`
  line_seperator=`echo $(for i in $(seq 1 ${full_width}); do printf "-"; done)`
  line_count=0
  node_count=1

  if [[ ${wide_flag} -eq 1 ]];then # wide mode: print out double column format
    queue_status=`printf '\n %-'${col_1}'s | %-'${col_2}'s | %-'${col_3}'s | %-'${col_4}'s || %-'${col_1}'s | %-'${col_2}'s | %-'${col_3}'s | %-'${col_4}'s ||' \
	    '■ Queue Name ■' '■ Type ■' '■■■■■■■■■■■ Q U E U E ■■■■■■ U S A G E ■■■■■■■■■■■' '■■■■■ Value ■■■■■' \
	    '■ Queue Name ■' '■ Type ■' '■■■■■■■■■■■ Q U E U E ■■■■■■ U S A G E ■■■■■■■■■■■' '■■■■■ Value ■■■■■'`
    queue_status='\n'${queue_status}`printf '\n%-'${half_screen_width}'s' ${line_seperator}`
  else # normal mode: print out single column format
    queue_status=`printf '\n %-'${col_1}'s | %-'${col_2}'s | %-'${col_3}'s | %-'${col_4}'s ||' \
	    '■ Queue Name ■' '■ Type ■' '■■■■■■■■■■■ Q U E U E ■■■■■■ U S A G E ■■■■■■■■■■■' '■■■■■ Value ■■■■■'`
    queue_status='\n'${queue_status}`printf '\n%-'${half_screen_width}'s' ${line_seperator}`
  fi

  qhost -q | sed '/-\+-/d' | sed 's/ \+ /\t/g' | sed '/HOSTNAME\|global/d' |
  while IFS= read -r line
  do
    determine_line=`expr ${line_count} % 2`
    if [[ ${determine_line} -eq 0 ]]; then
      node_name=`echo ${line} | cut -d' ' -f1`
      load_average=`echo ${line} | cut -d' ' -f4`
      total_mem=`echo ${line} | cut -d' ' -f5 | cut -d'.' -f1`
      using_mem=`echo ${line} | cut -d' ' -f6 | cut -d'.' -f1`
      line_count=`expr $line_count + 1`
    else
      queue_name=`echo ${line} | cut -d' ' -f1`
      all_slot=`echo ${line} | cut -d' ' -f3`
      total_slot=`echo ${all_slot} | cut -d'/' -f3`
      using_slot=`echo ${all_slot} | cut -d'/' -f2`
      line_count=`expr $line_count + 1`

      # slot risk measure
      slot_usage_ratio=`echo "scale=3;${using_slot} / ${total_slot}" \* 100 | bc`
      prt_slot_usage_ratio=`printf %.1f ${slot_usage_ratio}`
      slot_risk_ratio=`printf %.0f ${slot_usage_ratio}`
      reduction_slot_usage_ratio=`echo "${slot_usage_ratio}" / 2 | bc` # ratio reduction from 100 to 50 for space
      slot_risk_fg_color=`echo $(slot_risk_measure ${slot_risk_ratio}) | cut -d',' -f1`
      slot_risk_bg_color=`echo $(slot_risk_measure ${slot_risk_ratio}) | cut -d',' -f2`
      bar_slot_usage_ratio=`echo $(for i in $(seq 1 ${reduction_slot_usage_ratio}); \
      do printf "\033[${slot_risk_fg_color};${slot_risk_bg_color}m■\033[0m"; done)`
      remain_slot_usage_ratio=`echo "50 - ${reduction_slot_usage_ratio}" | bc`
      bar_remain_slot_usage_ratio=`echo $(for i in $(seq 1 ${remain_slot_usage_ratio}); \
      do printf "□"; done)`
      slot_ratio=$bar_slot_usage_ratio$bar_remain_slot_usage_ratio
      slot_num=${using_slot}/${total_slot}"("$prt_slot_usage_ratio"%%)"

      # memory risk measure
      mem_usage_ratio=`echo "scale=3;${using_mem} / ${total_mem}" \* 100 | bc`
      prt_mem_usage_ratio=`printf %.1f ${mem_usage_ratio}`
      mem_risk_ratio=`printf %.0f ${mem_usage_ratio}`
      reduction_mem_usage_ratio=`echo "${mem_usage_ratio}" / 2 | bc` # ratio reduction from 100 to 50 for space
      mem_risk_fg_color=`echo $(mem_risk_measure ${mem_risk_ratio}) | cut -d',' -f1`
      mem_risk_bg_color=`echo $(mem_risk_measure ${mem_risk_ratio}) | cut -d',' -f2`
      bar_mem_usage_ratio=`echo $(for i in $(seq 1 ${reduction_mem_usage_ratio}); \
      do printf "\033[${mem_risk_fg_color};${mem_risk_bg_color}m■\033[0m"; done)`
      remain_mem_usage_ratio=`echo "50 - ${reduction_mem_usage_ratio}" | bc`
      bar_remain_mem_usage_ratio=`echo $(for i in $(seq 1 ${remain_mem_usage_ratio}); \
      do printf "□"; done)`
      mem_ratio=$bar_mem_usage_ratio$bar_remain_mem_usage_ratio
      mem_num=${using_mem}G/${total_mem}G"("$prt_mem_usage_ratio"%%)"

      # load average risk measure
      load_usage_ratio=`echo "scale=3;${load_average}" / 1 | bc`
      prt_load_usage_ratio=`printf %.1f ${load_usage_ratio}`
      load_risk_ratio=`printf %.0f ${load_usage_ratio}`=
      reduction_load_usage_ratio=`echo "${load_usage_ratio}" / 2 | bc` # ratio reduction from 100 to 50 for space
      load_fg_color=`echo $(load_risk_measure ${load_average}) | cut -d',' -f1`
      load_bg_color=`echo $(load_risk_measure ${load_average}) | cut -d',' -f2`
      bar_load_usage_ratio=`echo $(for i in $(seq 1 ${reduction_load_usage_ratio}); \
      do printf "\033[${load_fg_color};${load_bg_color}m■\033[0m"; done)`
      remain_load_usage_ratio=`echo "50 - ${reduction_load_usage_ratio}" | bc`
      bar_remain_load_usage_ratio=`echo $(for i in $(seq 1 ${remain_load_usage_ratio}); \
      do printf "□"; done)`
      load_ratio=$bar_load_usage_ratio$bar_remain_load_usage_ratio
      load_num=${load_average}/100"("$prt_load_usage_ratio"%%)"

      if [[ ${wide_flag} -eq 1 ]];then # wide mode
	determine_node=`expr ${node_count} % 2`
        if [[ ${determine_node} -eq 1 ]]; then
	  tmp_line1=''
	  tmp_line2=''
	  tmp_line3=''
          # append result line
          tmp_line1=`printf ' %-'${col_1}'s| %-'${col_2}'s | %-'${col_3}'s | %-'${col_4}'s ||' \
  	          ${queue_name} 'slot' ${slot_ratio} ${slot_num}`
          tmp_line2=`printf ' %-'${col_1}'s| %-'${col_2}'s | %-'${col_3}'s | %-'${col_4}'s ||' \
  	          ${node_name} 'mem' ${mem_ratio} ${mem_num}`
          tmp_line3=`printf ' %-'${col_1}'s| %-'${col_2}'s | %-'${col_3}'s | %-'${col_4}'s ||' \
  	          '' 'load' ${load_ratio} ${load_num}`
	  node_count=`expr ${node_count} + 1`
        else
	  tmp_line1=${tmp_line1}`printf ' %-'${col_1}'s| %-'${col_2}'s | %-'${col_3}'s | %-'${col_4}'s ||' \
		  ${queue_name} 'slot' ${slot_ratio} ${slot_num}`
	  tmp_line2=${tmp_line2}`printf ' %-'${col_1}'s| %-'${col_2}'s | %-'${col_3}'s | %-'${col_4}'s ||' \
		  ${node_name} 'mem' ${mem_ratio} ${mem_num}`
	  tmp_line3=${tmp_line3}`printf ' %-'${col_1}'s| %-'${col_2}'s | %-'${col_3}'s | %-'${col_4}'s ||' \
		  '' 'load' ${load_ratio} ${load_num}`
	  queue_status='\n'${queue_status}'\n'${tmp_line1}'\n'${tmp_line2}'\n'${tmp_line3}'\n'`printf '%-'${half_screen_width}'s' ${line_seperator}`
	  node_count=`expr ${node_count} + 1`
        fi
      else # normal mode
	queue_status='\n'${queue_status}`printf '\n %-'${col_1}'s| %-'${col_2}'s | %-'${col_3}'s | %-'${col_4}'s ||' \
		${queue_name} 'slot' ${slot_ratio} ${slot_num}`
	queue_status='\n'${queue_status}`printf '\n %-'${col_1}'s| %-'${col_2}'s | %-'${col_3}'s | %-'${col_4}'s ||' \
		${node_name} 'mem' ${mem_ratio} ${mem_num}`
	queue_status='\n'${queue_status}`printf '\n %-'${col_1}'s| %-'${col_2}'s | %-'${col_3}'s | %-'${col_4}'s ||' \
		'' 'load' ${load_ratio} ${load_num}`
	queue_status='\n'${queue_status}`printf '\n%-'${half_screen_width}'s' ${line_seperator}`
	node_count=`expr ${node_count} + 1`
      fi
    fi
    if [[ ${line_number} -eq ${line_count} ]]; then
      printf "${queue_status}"
    fi
  done

  full_width_after=$(check_screen)
  if [[ ${full_width} -ne ${full_width_after} ]]; then # clear screen when the screen size is changed
    clear
  fi
}

main() {
  clear
  check_flag=$(check_sungridengine)
  if [[ ${check_flag} -eq 0 ]]; then
    :
  else
    printf '\nSun Grid Engine is not installed.\n'
    exit
  fi
  while true;
  do
    printf "\033[0;0H" # mouse cursor goes to (0,0)
    analysis_queue
    sleep 0.001 # refresh interval
  done
}
main "$0"

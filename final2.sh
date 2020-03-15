#!/bin/bash

g=(1000 1000 1000)						# g(s) for all nodes are set to infinte 

rhs=(1000 1000 0)						# rhs(s) of all except goal is set infinte and rhs(goal) = 0
open=(-1 -1 -1)							# open list is empty 
declare -A key
num_rows=3
num_columns=2
h=(0 1 1)                               			# heuristics calculated based on the no of hops from start node

# data collection
signal()
{                                                 
	a=($(iw dev wlan0 station dump))
	f=($(iw wlan0 mpath dump))                             
	c=${#a[@]}                   
	echo "size of an array is $c"                         
	echo "${f[12]} and ${f[22]}" | nc -c 192.168.10.1 5000
	echo "finished"                         
	v=($(nc -lp 5000))                      
	echo " ${v[2]} is the signal of ${v[0]}"
	g=10
	while [ $g -lt $c ]
	do
		if [ "${f[12]}" == "${a[g]}" ] || [ "${f[22]}" == "${a[g]}" ]
		then	
			ss=$(($g+30))
			break
		fi
		g=$(($g+1))
	done	

	if [ "${a[1]}" != "${v[0]}" ]
	then
		ds="${a[1]}"
	else
		ds="${a[g]}"
	fi
	nx="${v[0]}"
	a[31]=$((${a[31]}*-1))
	a[$ss]=$((${a[$ss]}*-1))
	v[2]=$((${v[2]}*-1))
	echo "$nx --1 || $ds --2"
	echo " ${a[1]} -- ${a[31]}  || ${v[2]} --- ${v[2]}  ||  ${a[$g]} -- ${a[$ss]}"
#	echo "Sab    ||  Sbc   ||  Sac "
#	a[31]=$((${a[31]}*-1))
#	a[$ss]=$((${a[$ss]}*-1))
#	v[2]=$((${v[2]}*-1))
}
signal

declare -A adj							#adjcency matrix has to path cost and need to be updated if cost changes 
num_rows=3
num_columns=3

adj[0,0]=0
adj[0,1]="${a[31]}"
adj[0,2]="${a[$ss]}"
adj[1,0]=1000
adj[1,1]=0
adj[1,2]="${v[2]}"
adj[2,0]=1000
adj[2,1]=1000
adj[2,2]=0

visited=(-1 -1 -1)

declare -i start=0                                		#start node; in our case its node '0'
declare -i goal=2 						# goal node; in our case its node '2'
			
declare -A sucs							# successors of each node
num_rows=3
num_columns=2
sucs[0,0]=1
sucs[0,1]=2
sucs[1,0]=2
sucs[1,1]=-1
sucs[2,0]=-1
sucs[2,1]=-1

declare -A pred							# predecessors of each node 
num_rows=3
num_columns=2
pred[0,0]=-1
pred[0,1]=-1
pred[1,0]=0
pred[1,1]=-1
pred[2,0]=0
pred[2,1]=1	

declare -i n=0

next=(-1 -1 -1)						#stores the next hop node of each node; path is extracted from this

cal_key () {	
	
	local i=0
	
	while [ $i -lt 3 ]
	d[31]=$((${a[31]}*-1))                                
        a[$ss]=$((${a[$ss]}*-1))                              
        v[2]=$((${v[2]}*-1))                                              
        echo "$nx --1 || $ds --2"                                         
        echo " ${a[1]} -- ${a[31]}  || ${v[2]} --- ${v[2]}  ||  ${a[$g]} -
#       echo "Sab    ||  Sbc   ||  Sac "                        o
	
		if [ ${g[${i}]} -ge ${rhs[${i}]} ]
			then
			key[${i},0]=$((${rhs[${i}]}+${h[${i}]}))                #calculating key value for each node
			key[${i},1]=${rhs[${i}]}

		else
			key[${i},0]=$((${g[${i}]}+${h[${i}]}))
			key[${i},1]=${g[${i}]}
			
		fi
		i=$(($i+1))
	done
	#visited[${i}]=-1
	return
}



add_visited (){                            #adding a node to visited list.												   // once added to the visited list it need not be removed even added to 
	
	local i=0 
	local -i n="$1"			   # open list once again.        ########################################################
	
	if [ ${visited[0]} -eq -1 ]
	then
		visited[0]=$n
	
	else
	
		while [[ "${visited[${i}]}" != -1 && "$i" -lt 2 ]]
		do	
			                                       
			i=$(($i+1))
		done
	
		visited[${i}]=$n
	fi
	return
}
rem_open () {
	local -i i=0
	local -i j=0
	local -i n="$1"                 ###############################################3
	
	
	
	
	while [ $i -lt 3 ]
	do
		if [ "$n" -eq "${open[${i}]}" ]
		then
			open[${i}]=-1                         # if s in open then remove 
			add_visited "$n"
			break					#changed: added break
		else
			i=$(($i+1))
		fi
	done
	
	
}
add_open () {	
	local -i i=0
	local -i n="$1"      #####################################################
	
	local -i j=0
	

	while  [ "${open[${i}]}" != -1 ] && [ "$i" -lt 3 ] && [ "$n" -lt 3 ]        #// adding s to open list       #changed [ ] must have space between all the chatacters in front and back
	do
		i=$(($i+1))
	done
	
	if [ "$n" -lt 3 ]                                                             #changed [ ] must have space between all the chatacters in front and back
	then
		open[${i}]="$n"
	fi
	
	
}
min_rhs (){
	local -i i=0
	local -i k=0
	local -i c=0

	#echo " value of n in rh cal" $n
	local -i min=1500                                                         # change: space btw min =1500
	local -i n="$1"                                           ####################################################
	
	
	for (( i=0; i<2; i++ ))
	do	
		k=${sucs[${n},${i}]}
		
		if [ "$k" != -1 ]
		then

			c=${adj[${n},${k}]}
			
			c=$(($c + ${g[${k}]}))					#change: added $(( )) to right side
			
			if [ "$min" -gt "$c" ]                           #changed: convert from lt to gt
			then
				min="$c"
				
				next[${n}]="$k"                     #storing the path 
		
			
			fi
		fi
	done
	
	rhs[$n]="$min"
	
	
}
update_state (){	
	local -i n="$1"                                # ####################################
	
	local -i i=0
	local -i flag=0
	local -i flag2=0
		cal_key 
	
	
	while [ $i -lt 3 ]                           # s not visited
	do
		if [ $n=${visited[${i}]} ]
		then
			flag=1;
			break
		else
		
		  i=$(($i+1))
		fi
	done
	if [ $flag -eq 0 ]
	then
			g[$n]=1000; 
			 
		                        #  g(s) = infinite
	fi
	
	if [ $n != $goal ]
	then	
		
		min_rhs "$n"                               # rhs = min {c(s,s') + g(s') where s' belongs to succ of s} 
	fi
	i=0
	
	while [ $i -lt 3 ]
	do
		if [ ${open[${i}]} != -1 ] && [ ${open[${i}]} = $n ]
		then
			flag2=1									#	// if s is in open list  
		fi
		i=$(($i+1))
	done
	if [ "$flag2" = 1 ]
	then
		rem_open "$n"                             # remove s from open list
	fi
	
		
	if [ ${g["$n"]} != ${rhs["$n"]} ]                      # if s is inconsistant i.e. g(s)!=rhs(s) 
	then
		add_open "$n"
		                         # if g(s)!=rhs(s) then add to open list
	fi
	
	
}
min_key (){                                  #finds the minimum key and returns to the check loop function 
		
	local -i min=2
	local -i i=0
	local -i j
	local -i flag=0									
	
	cal_key
	j=-1                                                        
	i=0
	min=-1
	if [ "${open[0]}" != -1 ]                  ######################################################### need some watch 
	then
		min=0	
		i=1
		
		while [ "${open[${i}]}" != -1 ] && [ "$i" -lt 3 ]              # changed added a space between "$i"<->-lt
		do
			if [ "${key[${open[${i}]},0]}" -lt "${key[${open[${min}]},0]}" ]                # changed added " " to all variables
				then
					min="$i"
				
			elif [ "${key[${open[${i}]},1]}" -lt "${key[${open[${min}]},1]}" ] && [ "${key[${open[${i}]},0]}" == "${key[${open[${min}]},0]}" ]
				then
					min="$i"
				
			else
					i=$(($i+1))
			fi
		done
	fi
	n=${open["$min"]}
	
			
		
	return "$min"
}
check_loop(){
	local -i i
	local -i j
	local -i min=0
	
	cal_key
	
	min_key
	min="$?"
	if [ "$n" -eq -1 ]
	then	
											# changed: new condition was added to stop expansion of -1 
		return "0"
	fi

	
	if [ "$min" -eq -1 ]
	then	
		
		return "0"
	fi
	
	

	if [[ "${key[${n},0]}" -lt "${key[${start},0]}" ]]
	then
			return "1"
			
	
	elif [ "${key[${n},1]}" -lt "${key[${start},1]}" ]
	then
			return "1"                                          # // checking the initial condition to enter shortest path
		
	
	elif [ "${rhs[${start}]}" != "${g[${start}]}" ]
	then
			return "1"
		
	fi
	
	
	return "0"
		
		
		
}
shortest_path (){	
	
	local -i i=0
	local -i z
	check_loop
	f="$?"
	while [ $f -eq 1 ]
	do	
		
		rem_open "$n"
		
		
		if [ "${g[${n}]}" -gt "${rhs[${n}]}" ]
		then	
			
			local -i i=0
			g[${n}]=${rhs[${n}]}
			
			while [ "$i" -lt 2 ] && [ ${pred["${n}","${i}"]} != -1 ]
			do   
				
				update_state "${pred[${n},${i}]}"
				
				i=$(($i + 1))      
				   									# // update predecesor of s
			done
			
			cal_key
		
		
		elif [ ${g[${n}]} -lt ${rhs[${n}]} ]                           #  // update predecesor U {s};  meaning updating s and then its preds       
		then		
			g[${n}]=1000											#// g[s] = infinite
			update_state "$n"                             	
			i=0
			while [ "$i" -lt 2 ] && [ ${pred[${n},${i}]} != -1 ]
			do   
				update_state "${pred[${n},${i}]}" 				#// updating pred of s
				i=$(($i + 1))                 			#changed: given space in front and back of +                                 
			done
			
		fi
		check_loop
		f="$?"
	done
}
print_path ()
{	
	local -i i=0
	#printf("\nPath is %d ",start);
	for (( i=0; i<2; i++ ))
	do
	
		if [ "${next[${i}]}" != "$goal" ]
		then
			echo "------>" ${next[${i}]}   
		                                									#  // printing path
		elif [ "${next[${i}]}" == "$goal" ]
		then
			echo -n "------>" ${next[${i}]}
			#iw wlan0 mpath new $ds next_hop $ds
			#printf("---> %d\n",next[i]);
			break
		fi
	done
	if [ $i -eq 0 ]
	then
		iw wlan0 mpath new $ds next_hop $ds
	else
		iw wlan0 mpath new $ds next_hop $nx
	fi
	return	
}
change_cost()
{	
	local -i s
	local -i d
	local -i cost
	#// Test space for twin route replanning
	
	local -i node
	local -i s2
	local -i d2
	local -i cost2
	local -i i
	local -i source1
	local -i dest1
	local -i source2
	local -i dest2
#//	printf("\n Enter the node to be moved ");
#//	scanf("%d",&node);                                                         // node to be moved
	signal
	read kl
	v[2]=$((${v[2]}+kl))
	read gl
	a[31]=$((${a[31]}+gl))
	echo "${v[2]}  ---- ${a[31]}"
	s01=$((${adj[0,1]}-${a[31]}))
	s02=$((${adj[0,2]}-${a[$ss]}))
	s12=$((${adj[1,2]}-${v[2]}))
	echo "difference ||  $s01   ||   $s12   ||  $s02"
#######################################
	if [ $s01 -lt -2 ] || [ $s01 -gt 2 ]
	then
		#adj[0,1]=${a[31]}
		echo "flag s"
		s=0
		d=1
		cost=${a[31]}
	elif [ $s02 -lt -2 ] || [ $s02 -gt 2 ]
	then
		#adj[0,2]=${a[ss]}
		echo "flag s_1"
		s=0
		d=2
		cost=${a[ss]}
	elif [ $s12 -lt -2 ] || [ $s12 -gt 2 ]
	then
		#adj[1,2]=${v[2]}
		echo "flag s_2" 
		s=1
		d=2
		cost=${v[2]}
	fi
#########################################

	#echo "Enter source node"
	#read s
	#echo "Enter desti node"
	#read d
	#echo "cost"
	#read cost
	#echo "cost updates"
#	update_state"$s"                                             updating 1st link
	#adj[${s2},${d2}]=$cost2;
	for(( i = 0; i<2; i++ ))
	do
		if [[ "${sucs[${s},${i}]}" == "$d" ]]        # changed: = --> == and added {} to the parameters of the array
		then
			adj[${s},${d}]=$cost
			source1=$s
			dest1=$d		#// finding the source and destination node from the link
						
			break

		elif [[ "${pred[${s},${i}]}" == "$d" ]]
		then
			adj[${d},${s}]=$cost
			source1=$d
			dest1=$s
			
			break
		fi
	done
	
	
#############################
	if [ $s01 -lt -2 ] || [ $s01 -gt 2 ] && [ $s != 0 ] && [ $d != 1 ]
	then
		#adj[0,1]=${a[31]}
		echo "flag s2"
		s2=0
		d2=1
		cost2=${a[31]}
	elif [ $s02 -lt -2 ] || [ $s02 -gt 2 ] && [ $s != 0 ] && [ $d != 2 ]
	then
		#adj[0,2]=${a[ss]}
		echo "flag s2_1"
		s2=0
		d2=2
		cost2=${a[ss]}
	elif [ $s12 -lt -2 ] || [ $s12 -gt 2 ] && [ $s != 1 ] && [ $d != 2 ]
	then
		#adj[1,2]=${v[2]}
		echo "flag s2_2"
		s2=1
		d2=2
		cost2=${v[2]}
	fi
#########################################
	#echo "Enter source node"
	#read s2
	#echo "Enter desti node"
	#read d2
	#echo "cost"
	#read cost2
	#echo "cost updates"
	#adj[${s2},${d2}]=$cost2
	for(( i=0; i<2; i++ ))
	do
		if [ "${sucs[${s2},${i}]}" == "$d2" ]        #changed: = --> ==
		then
			adj[${s2},${d2}]=$cost2
			source2=$s2
			dest2=$d2			  # // finding the source and destination node from the link
						
			break

		elif [ "${pred[${s2},${i}]}" == "$d2" ]        #changed: = --> ==
		then
			adj[${d2},${s2}]=$cost2
			source2=$d2
			dest2=$s2
			
			break
		fi
	done

	

	#// characterisation block for finding the moved node
	
	if [ "$source1" == "$dest2" ]
	then	
		
		node=$source1

	elif [ "$source2" == "$dest1" ]
	then
		
		node=$source2
	elif [ "$source2" == "$source1" ]        #changed: add for start
	then							# changed: added condition which is not on C++ code 
		
		node=$source2
	elif [ "$dest2" == "$dest1" ]
	then					 #changed: add for goal
		
		node=$dest2
	fi
	
	
	#//characterisation done; node identified
	if [ "$node" == 1 ]                                                          
	then
		update_state "1"     #   // update preference for different nodes
		update_state "$start"
		cal_key
	
	elif [ "$node" == "$start" ]
	then
		update_state "$start"
		cal_key
	
	elif [ "$node" == "$goal" ]                      # changed: -eq to == 
	then
		update_state "1"
		update_state "$start"
		cal_key
	fi
	
	
	shortest_path
	cal_key
	print_path
}

main (){	
	local -i i=0
	local -i j=0
	
	
	g[2]=1000											#// 1000 ~ infinite
	rhs[2]=0											#		// Initilization
	open[0]=2
	echo "main"
	
	cal_key 
	shortest_path 
	cal_key
	print_path                        				#first run
	i=1	
	while [ $i -eq 1 ]
	do
		change_cost  #changing the cost for 3 times as i<3
		#i=$(($i+1))
	done
	return 0
		
}
main


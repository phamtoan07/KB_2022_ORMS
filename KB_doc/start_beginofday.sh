#!/bin/bash
URLS=("POST http://10.200.39.73:8686/bo-ors/data/beginofday" \
"POST http://10.200.39.71:8582/admin/clear-data" \
"POST http://10.200.39.71:8582/orssvr/data/beginofday" \
"POST http://10.200.39.71:8282/cache/accounts/all" \
"POST http://10.200.39.72:8282/cache/accounts/all" \
"POST http://10.200.39.74:8883/cache/accounts/all" \
"POST http://10.200.39.71:8582/cache/accounts/all" \
"POST http://10.200.39.72:8582/cache/accounts/all")

SSHCMDS=("ssh karaf@10.200.39.73 -p 8101 restart \"FSS I-OMS System\"" \
"ssh karaf@10.200.39.73 -p 8102 restart \"FSS BO-OMS System\"" \
"ssh karaf@10.200.39.74 -p 8101 restart \"FSS I-OMS System\"")

echo -n "Enter password: "
read -e VALUE

password=`echo -n $VALUE|md5sum`
pwdchk="e10adc3949ba59abbe56e057f20f883e  -"
if [ "$password" = "$pwdchk" ]; then
        i=0
	j=0
	h=0
        read -p "Are you sure run synchronizer now? Press 'yes' to continue:" yn
        if [ $yn == "yes" ];then
                 echo "Let's Synchroniez...$(date)............................." | tee -a out.txt
				 for i in "${URLS[@]}" 
				 do
					echo "" | tee -a out.txt
					echo "STEP $j" | tee -a out.txt
					j=$((j+1))
					echo "BEGIN time=$(date) ----> "$i | tee -a out.txt
					status_code=$(curl -o ~res.tmp -s -w "%{http_code}\n" -X $i)
					if [ $status_code == 200 ];then
                        echo ".....OK ---$(date) ---->"$i"==>["`cat ~res.tmp`"]" | tee -a out.txt
					else
                        echo ".....FAIL -$(date) ---->"$i"==>["`cat ~res.tmp`"]" | tee -a out.txt
						exit 0
					fi
				 done
				 echo "Let's Restarting using CMD ...$(date)..................." | tee -a out.txt
				 for u in "${SSHCMDS[@]}" 
				 do
					echo "" | tee -a out.txt
					echo "STEP $j" | tee -a out.txt
					h=$((h+1))
					echo "IOMS $h" | tee -a out.txt
					j=$((j+1))
					echo "BEGIN time=$(date) ----> "$u | tee -a out.txt
					echo $u
					ssh_code=$($u)
					if [ "$ssh_code" == "" ];then
                        echo ".....OK ---$(date) ---->"$u"==>["$ssh_code"]" | tee -a out.txt
					else
                        echo ".....FAIL -$(date) ---->"$u"==>["$ssh_code"]" | tee -a out.txt
						exit 0
					fi
				 done
				 echo "DONE Restarted................$(date)..................." | tee -a out.txt
        else
                                echo "Goodbye !!!" | tee -a out.txt
                                 exit 0
        fi
else

                echo "incorrect password"
                         exit 0
fi




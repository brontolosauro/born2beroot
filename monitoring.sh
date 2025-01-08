#! /usr/bin/bash

touch message.txt

#Architecture
echo -n "#Architecture: " >> message.txt
uname -m >> message.txt

#kernel version
echo -n "#Kernel Version: " >> message.txt
uname -r >> message.txt

#number of physical processors
echo -n "#CPU physical: " >> message.txt
awk '/physical id|cpu cores/ {
	if ($1 == "physical")
		i = $4
	if ($1 == "cpu")
		cores[i] = $4
}
END {
	cores_qty = 0
	for (x in cores)
		cores_qty += cores[x]
	print cores_qty
}' /proc/cpuinfo >> message.txt
	
#number of virtual processors
echo -n "#vCPU: " >> message.txt
grep "processor" /proc/cpuinfo | wc -l >> message.txt

#avilable RAM
echo -n "#Memory Usage: " >> message.txt
awk '/Mem/ {
#	print $0
	mem[$1] = $2 / 1000000
}
END {
#	for (x in mem)
#		print x mem[x]
#	print mem["MemAvailable:"]
	rate = mem["MemAvailable:"] / mem["MemTotal:"] * 100
	printf "%.2f", mem["MemAvailable:"]
	printf "/%.2f GB", mem["MemTotal:"]
	printf "(%.2f %%)\n", rate
}' /proc/meminfo >> message.txt

#disk usage
echo "#Disk Usage: " >> message.txt
df | awk '/root/ {
	size += $2
	used += $3
	free += $4
	size = size * 1024 / 1000000000
	used = used * 1024 / 1000000000
	free = free * 1024 / 1000000000

}
END {
	rate = used / size * 100
	printf "\t/\t %.2f/%.2f GB (%.3f %%)\n", free, size, rate
}' >> message.txt
df | awk '/home/ {
	size += $2
	used += $3
	free += $4
	size = size * 1024 / 1000000000
	used = used * 1024 / 1000000000
	free = free * 1024 / 1000000000

}
END {
	rate = used / size * 100
	printf "\t/home\t %.2f/%.2f GB (%.3f %%)\n", free, size, rate
}' >> message.txt

#CPU load
echo -n "#CPU load: " >> message.txt

awk '/cpu / {
	for (i = 1; i <= 11; i++)
		tot_t += $i
	idle_t = $5
	load_t = tot_t - idle_t
	load_rate = load_t / tot_t * 100
}
END {
	printf "%.2f %%\n", load_rate
}' /proc/stat >> message.txt

#last boot
echo -n "#Last boot: " >> message.txt
who -b |awk '{print $4 " " $5}' >> message.txt

#LVM
echo -n "#LVM in use: " >> message.txt
if [[(($(lsblk | grep "lvm" | wc -l) -gt 0))]];
	then
		echo yes >> message.txt;
	else
		echo no >> message.txt;
fi

#active connections
echo -n "#TCP Connections: " >> message.txt
ss -at | grep "ESTAB" | wc -l >> message.txt

#number of users loged in
echo -n "#Logged On Users: " >> message.txt
who | wc -l >> message.txt

#IPv4 & MAC address
echo "#IPv4 Address: " >> message.txt
ip addr | awk '/link\/ether|enp/ {
	if ($1 == "link/ether")
		mac = $2
	if ($1 == "inet")
	{
		ip = $2
		printf "\t%s (%s)\n", ip, mac
	}
}' >> message.txt

#sudo 
echo -n "#Commands Executed Via sudo: " >> message.txt
journalctl -q _COMM=sudo | grep COMMAND | wc -l >> message.txt

#wall
wall message.txt
rm message.txt

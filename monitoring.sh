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
echo -n "#Disk Usage: " >> message.txt
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
	printf "\t\t/home\t %.2f/%.2f GB (%.3f %%)\n", free, size, rate
}' >> message.txt

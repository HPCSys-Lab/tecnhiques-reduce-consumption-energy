# printar as informações do cpu
echo "Informações sobre o CPU:\n"
cat /proc/cpuinfo
lscpu

# resetar todos os cpus virtuais
echo "Resetando todos os CPUs virtuais"
cset shield --reset --force

# setar os novos cpus disponiveis
echo "Criando novos CPUs virtuais"

### this code run only in machines with docker installed
# echo "stop all dockers"
# docker stop $(docker ps)
# echo "set docker cpuset empty"
# echo > /sys/fs/cgroup/cpuset/docker/cpuset.cpus
# echo "starting cpu container"

cset shield -c 0,1,2,3 -k on --force

# quantas vezes o programa irá rodar $NUM_RUNS
for i in $(seq 1 3);
do
	echo "Rodando na frequencia 500MHz x 500MHz com a governança userspace"
	# setar a frequencia nova nestes cpus
	cpufreq-set -c 0,1,2,3 -d 500MHz -u 500MHz -g userspace
	./moa-exec.sh -f 500 -F 500

	echo "Rodando na frequencia 1000MHz x 1000MHz com a governança userspace"
	cpufreq-set -c 0,1,2,3 -d 1000MHz -u 1000MHz -g userspace
	./moa-exec.sh -f 1000 -F 1000
	
	echo "Rodando na frequencia 2000MHz x 2000MHz com a governança userspace"
	cpufreq-set -c 0,1,2,3 -d 2000MHz -u 2000MHz -g userspace
	./moa-exec.sh -f 2000 -F 2000

	echo "Rodando na frequencia 3200MHz x 3200MHz com a governança userspace"
	cpufreq-set -c 0,1,2,3 -d 3200MHz -u 3200MHz -g userspace
	./moa-exec.sh -f 3200 -F 3200
done

echo "Retorna padrão do CPU"
cset shield --reset --force
cpufreq-set -c 0,1,2,3 -d 500MHz -u 3200MHz
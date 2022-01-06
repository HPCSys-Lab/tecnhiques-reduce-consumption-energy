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
	echo "Rodando na frequencia 600MHz x 600MHz com a governança userspace"
	# setar a frequencia nova nestes cpus
	cpufreq-set -c 0,1,2,3 -d 600MHz -u 600MHz -g userspace
	./moa-exec-socket-600.sh -f 600 -F 600

	echo "Rodando na frequencia 800MHz x 800MHz com a governança userspace"
	cpufreq-set -c 0,1,2,3 -d 800MHz -u 800MHz -g userspace
	./moa-exec-socket-800.sh -f 800 -F 800
	
	echo "Rodando na frequencia 1000MHz x 1000MHz com a governança userspace"
	cpufreq-set -c 0,1,2,3 -d 1000MHz -u 1000MHz -g userspace
	./moa-exec-socket-1000.sh -f 1000 -F 1000

	echo "Rodando na frequencia 1200MHz x 1200MHz com a governança userspace"
	cpufreq-set -c 0,1,2,3 -d 1200MHz -u 1200MHz -g userspace
	./moa-exec-socket-1200.sh -f 1200 -F 1200
done

echo "Retorna padrão do CPU"
cset shield --reset --force
cpufreq-set -c 0,1,2,3 -d 600MHz -u 3200MHz
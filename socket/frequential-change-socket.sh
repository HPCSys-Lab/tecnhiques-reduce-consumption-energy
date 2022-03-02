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

cset shield -c 0 -k on --force

echo "Rodando na frequencia 600MHz x 600MHz com a governança userspace"
# setar a frequencia nova nestes cpus
cpufreq-set -c 0,1 -d 600MHz -u 600MHz -g userspace
./moa-exec-socket-600.sh -cpus 2 -f 600 -F 600

echo "Rodando na frequencia 1200MHz x 1200MHz com a governança userspace"
cpufreq-set -c 0,1 -d 1200MHz -u 1200MHz -g userspace
./moa-exec-socket-1200.sh -cpus 2 -f 1200 -F 1200

cset shield -c 0,1 -k on --force

echo "Rodando na frequencia 600MHz x 600MHz com a governança userspace"
# setar a frequencia nova nestes cpus
cpufreq-set -c 0,1 -d 600MHz -u 600MHz -g userspace
./moa-exec-socket-600.sh -cpus 2 -f 600 -F 600

echo "Rodando na frequencia 1200MHz x 1200MHz com a governança userspace"
cpufreq-set -c 0,1 -d 1200MHz -u 1200MHz -g userspace
./moa-exec-socket-1200.sh -cpus 2 -f 1200 -F 1200

cset shield -c 0,1,3 -k on --force

echo "Retorna padrão do CPU"
cset shield --reset --force
cpufreq-set -c 0,1,2,3 -d 600MHz -u 1200MHz
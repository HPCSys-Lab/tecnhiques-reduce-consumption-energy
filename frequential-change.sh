# printar as informações do cpu
echo "Informações sobre o CPU:\n"
cat /proc/cpuinfo
lscpu

# resetar todos os cpus virtuais
echo "Resetando todos os CPUs virtuais"
sudo cset shield --reset --force

# setar os novos cpus disponiveis
echo "Criando novos CPUs virtuais"
cset shield -c 0,1,2,3 -k on --force

function run_minibatching_without_dvfs_and_dpm {
	echo "Retorna padrão do CPU"
	cset shield --reset --force
	cpufreq-set -c 0,1,2,3 -d 600MHz -u 1200MHz

	echo "Rodando na frequencia máxima"
	sudo cpufreq-set -c 0,1,2,3 -d 600MHz -u 1200MHz -g performance
	./moa-exec.sh -f 600 -F 1200 -c 4
}

function run_4_cores_minimum_and_maximum_frequency {
    echo "Resetando todos os CPUs virtuais"
    sudo cset shield --reset --force

	echo "Rodando na frequencia minima"
	sudo cpufreq-set -c 0,1,2,3 -d 600MHz -u 600MHz -g powersave
	./moa-exec.sh -f 600 -F 600 -c 4

	echo "Rodando na frequencia máxima"
	sudo cpufreq-set -c 0,1,2,3 -d 1200MHz -u 1200MHz -g powersave
	./moa-exec.sh -f 1200 -F 1200 -c 4
}

function run_2_cores_minimum_and_maximum_frequency {
    echo "Resetando todos os CPUs virtuais"
    sudo cset shield --reset --force

	echo "Rodando na frequencia minima"
	sudo cpufreq-set -c 0,1 -d 600MHz -u 600MHz -g powersave
	./moa-exec.sh -f 600 -F 600 -c 2

	echo "Rodando na frequencia máxima"
	sudo cpufreq-set -c 0,1 -d 1200MHz -u 1200MHz -g powersave
	./moa-exec.sh -f 1200 -F 1200 -c 2
}

function reset_cpu {
	echo "Retorna padrão do CPU"
	cset shield --reset --force
	cpufreq-set -c 0,1,2,3 -d 600MHz -u 1200MHz
}

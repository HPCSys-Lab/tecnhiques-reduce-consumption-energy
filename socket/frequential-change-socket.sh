# printar as informações do cpu
echo "Informações sobre o CPU:\n"
cat /proc/cpuinfo
lscpu

# resetar todos os cpus virtuais
echo "Resetando todos os CPUs virtuais"
sudo cset shield --reset --force

# setar os novos cpus disponiveis
echo "Criando novos CPUs virtuais"

function run_only_mini_batching {
    echo "Resetando todos os CPUs virtuais"
    sudo cset shield --reset --force

	echo "Rodando na frequencia padrão"
	sudo cpufreq-set -c 0,1,2,3 -d 600MHz -u 1200MHz -g performance
	./moa-exec-minibatching.sh -f 600 -F 1200
}

function run_only_mini_batching_to_xu3em {
    echo "Resetando todos os CPUs virtuais"
    sudo cset shield --reset --force

	echo "Rodando na frequencia 600x600"
	sudo cpufreq-set -c 0,1,2,3 -d 600MHz -u 600MHz -g powersave
	./moa-exec-minibatching.sh -f 600 -F 600

	echo "Rodando na frequencia 1200x1200"
	sudo cpufreq-set -c 0,1,2,3 -d 1200MHz -u 1200MHz -g powersave
	./moa-exec-minibatching.sh -f 1200 -F 1200

}

function run_xue3m_without_mini_batching_paralel_2_cpu {
    sudo cset shield -c 0,1 -k on --force

    echo "Rodando na frequencia 600MHz x 600MHz com a governança powersave"
    # setar a frequencia nova nestes cpus
    sudo cpufreq-set -c 0,1 -d 600MHz -u 600MHz -g powersave
    ./moa-exec-xue3m-600.sh -c 2 -f 600 -F 600

    echo "Rodando na frequencia 1200MHz x 1200MHz com a governança powersave"
    sudo cpufreq-set -c 0,1 -d 1200MHz -u 1200MHz -g powersave
    ./moa-exec-xue3m-1200.sh -c 2 -f 1200 -F 1200
}

function run_xue3m_without_mini_batching_paralel_3_cpu {
    sudo cset shield -c 0,1,2 -k on --force

    echo "Rodando na frequencia 600MHz x 600MHz com a governança powersave"
    # setar a frequencia nova nestes cpus
    sudo cpufreq-set -c 0,1,2 -d 600MHz -u 600MHz -g powersave
    ./moa-exec-xue3m-600.sh -c 3 -f 600 -F 600

    echo "Rodando na frequencia 1200MHz x 1200MHz com a governança powersave"
    sudo cpufreq-set -c 0,1,2 -d 1200MHz -u 1200MHz -g powersave
    ./moa-exec-xue3m-1200.sh -c 3 -f 1200 -F 1200
}

function reset_cpus_and_freq {
    echo "Retorna padrão do CPU"
    sudo cset shield --reset --force
    sudo cpufreq-set -c 0,1,2,3 -d 600MHz -u 1200MHz
}

run_only_mini_batching
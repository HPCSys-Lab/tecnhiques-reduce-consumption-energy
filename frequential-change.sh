echo "Criando as pastas de resultados..."

mkdir /home/pi/reginaldojunior/experimentos/1_2_3_4/
mkdir /home/pi/reginaldojunior/experimentos/1_2_3_4/600MHzx600MHz
mkdir /home/pi/reginaldojunior/experimentos/1_2_3_4/900MHzx900MHz
mkdir /home/pi/reginaldojunior/experimentos/1_2_3_4/1200MHzx1200MHz

# printar as informações do cpu
echo "Informações sobre o CPU:\n"
cat /proc/cpuinfo
lscpu

# resetar todos os cpus virtuais
echo "Resetando todos os CPUs virtuais"
cset shield --reset --force

# setar os novos cpus disponiveis
echo "Criando novos CPUs virtuais"
cset shield -c 0,1,2,3 -k on --force

# quantas vezes o programa irá rodar $NUM_RUNS
for i in $(seq 1 3);
do
	echo "Rodando na frequencia 600MHz x 600MHz com a governança powersave"
	# setar a frequencia nova nestes cpus
	cpufreq-set -c 0,1,2,3 -d 600MHz -u 600MHz -g powersave
	./moa-exec.sh -f 600 -F 600

	echo "Rodando na frequencia 900MHz x 900MHz com a governança powersave"
	cpufreq-set -c 0,1,2,3 -d 900MHz -u 900MHz -g powersave
	./moa-exec.sh -f 900 -F 900
	
	echo "Rodando na frequencia 1200MHz x 1200MHz com a governança powersave"
	cpufreq-set -c 0,1,2,3 -d 1200MHz -u 1200MHz -g powersave
	./moa-exec.sh -f 1200 -F 1200
done

echo "Retorna padrão do CPU"
cset shield --reset --force
cpufreq-set -c 0,1,2,3 -d 600MHz -u 1200MHz
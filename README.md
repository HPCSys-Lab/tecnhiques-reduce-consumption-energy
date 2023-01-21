# Comparison XUE3M and Mini-Batching

This project is base code to support experiments of paper about XUE3M with mini batching.
 XUE3M is tecnhique that use Dynamic Voltage and Dynamic Scalling to found better configs in
 performance and energy consumer. Mini Batching is implemented in data stream framework MOA, using 
 concepts of Dynamic Power Management more specify Memory state. 

## Dependends

* cpuset_1.5.6-5.1_all.deb
* libcpufreq0_008-1.1_armhf.deb
* cpuset_1.5.6-5.1_all.deb

All packages is disponible in folder /packages. To install only run `sudo dpkg -i package-name.deb`

## How to use

First step, is set number of cores disponibles in script `frequential-change.sh`. You can to change same file to modify frequencies.

After changed this. You can run follow command.

```
sudo chmod +x frequential-change.sh
sudo chmod +x moa-exec.sh
sudo ./frequential-change.sh > out.txt &
```

## How to read results and notebooks

Results and notebooks are divided by type experiment. Each experiment is executed three times with same configurations this because happen a distortion other experiment is confirme results. So, first see results experiments. This folder had files of type csv dumped by MOA.

Folder follow structure:

    - results
        - coletor-energia
            - example: {techique}
            - dpm
            - dvfs
            - mini-batching
            ...
        - loop-fusion
            - example: {description of experiment}
            - coletor-energia
                - previa {previa foi a execução limitando os algoritmos e datasets}
                - final
        - sem-coletor
        - speedup
            - example: {device-tecnhique}
            - m1-loopfusion
            - pi-loopfusion
            - pi-without-loopfusion

In folder notebooks the structure is similar results. Each folder is represent a tecnhique in had parser and code with python necessary to plot graphs. Highlights notebooks

 - [Comparison with loop fusion mini-batching and without loop fusion mini-batching results](./notebooks/mini-batching/Comparison-MiniBatchsExperiences.ipynb)
 - [Comparison XUE3M tecnhique (DVFS, DPM) with mini-batching results](./notebooks/dvfs/Comparison-XUE3M-MiniBatching.ipynb)
 - [Results mini-batching reproduce and big batches (500, 2000) and small batches (5, 15) analisys](./notebooks/mini-batching/MOA-MiniBatching-Batchs.ipynb)
  - [Results with comparisons MB-LF and DVFS/DPM analysis research](./notebooks/dvfs/comparison-mb-dvfs-tecnhiques-mblf.ipynb)
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

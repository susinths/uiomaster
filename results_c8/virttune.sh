#!/usr/bin/env bash
set_irq_affinity.sh ens2

virsh numatune vm8 --nodeset 0
virsh emulatorpin vm8  0-3
for i in {0..3}; do virsh vcpupin vm8 $i $i;done

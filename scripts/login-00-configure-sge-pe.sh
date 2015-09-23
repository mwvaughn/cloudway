#!/bin/bash

echo "Configuring SGE parallel environments..."

for WAY in {1..16}
do
echo "pe_name            ${WAY}way
slots              9999
user_lists         NONE
xuser_lists        NONE
start_proc_args    /bin/true
stop_proc_args     /bin/true
allocation_rule    \$fill_up
control_slaves     TRUE
job_is_first_task  FALSE
urgency_slots      min
accounting_summary FALSE
qsort_args         NONE
" > pe${WAY}way
echo "Adding -pe pe${WAY}way"
sudo -s /bin/bash -c "export SGE_ROOT=/opt/sge; /opt/sge/bin/lx-amd64/qconf -Ap pe${WAY}way" sgeadmin
sudo -s /bin/bash -c "export SGE_ROOT=/opt/sge; /opt/sge/bin/lx-amd64/qconf -aattr queue pe_list ${WAY}way all.q" sgeadmin
rm -rf pe${WAY}way
done


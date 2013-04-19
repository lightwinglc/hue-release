#set -x
set -e

# forward ports 
# $ netstat -lntu | awk '{print $4}' | grep "[0-9]*$" -o | sort -nu
#
# build Vagrant config:
# $ netstat -lntu | awk '{print $4}' | grep "[0-9]*$" -o | sort -nu | \
#      (id=42000; while read x; do echo config.vm.forward_port $x, $id; id=$(($id+1));  done)

vagrant up
vagrant ssh -c "echo 'vbox' | sudo tee /virtualization"
vagrant halt
MACHINE="$(VBoxManage list vms | grep `cat .vagrant/machines/default/virtualbox/id` | sed -r 's/\"(.*)\".*/\1/g')"
echo $MACHINE
VBoxManage modifyvm "$MACHINE" --memory 2048 --cpus 2
VBoxManage export "$MACHINE" --output "$MACHINE VirtualBox".ova \
    --vsys 0 --vendor "HortonWorks" --version "Caterpillar" --product "Sandbox"

vagrant up --no-provision
vagrant ssh -c "sudo /opt/VBoxGuestAdditions-*/uninstall.sh"
vagrant ssh -c "echo 'vmware' | sudo tee /virtualization"
vagrant halt

HDDFILE="$(VBoxManage list hdds | grep -e "$MACHINE/" | sed -r "s/.*:[^/]*(.*)/\1/g")"
cp "$HDDFILE" ./vmware/sandbox.vmdk
ovftool ./vmware/vmware.vmx "./$MACHINE VMware.ova"


vagrant up --no-provision
vagrant ssh -c "sudo /boot/grub/menu.lst noapic"
vagrant ssh -c "echo 'hyper-v' | sudo tee /virtualization"
vagrant halt
VBoxManage clonehd "$HDDFILE" ./hyper-v/sandbox.vhd --format vhd

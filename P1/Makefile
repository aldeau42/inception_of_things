all:
	vagrant up

clean:
	rm -rf .vagrant
	sudo systemctl restart virtualbox
	
kvm:
	sudo rmmod kvm_intel
	sudo rmmod kvm


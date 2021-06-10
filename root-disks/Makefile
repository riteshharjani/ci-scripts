IMAGES += ppc64-rootfs.cpio.gz ppc64-novsx-rootfs.cpio.gz ppc64le-rootfs.cpio.gz
IMAGES += ppc-rootfs.cpio.gz
IMAGES += cloud-init-user-data.img
IMAGES += ubuntu21.04-cloudimg-ppc64el.qcow2

all: $(IMAGES)

ppc64-rootfs.cpio.gz: ppc64-novsx-rootfs.cpio.gz
	ln -s $< $@

ppc64-novsx-rootfs.cpio.gz:
	wget -O $@ "https://github.com/groeck/linux-build-test/blob/4e693ba1cfc17ff4c551626855d2982c492be1c2/rootfs/ppc64/rootfs.cpio.gz?raw=true"

ppc64le-rootfs.cpio.gz:
	wget -O $@ "https://github.com/groeck/linux-build-test/blob/4e693ba1cfc17ff4c551626855d2982c492be1c2/rootfs/ppc64/rootfs-el.cpio.gz?raw=true"

ppc-rootfs.cpio.gz:
	wget -O $@ "https://github.com/groeck/linux-build-test/blob/65335f1a683166c7b83d61a3eeaf400ebcfa20dd/rootfs/ppc/rootfs.cpio.gz?raw=true"

ubuntu21.04-cloudimg-ppc64el.qcow2:
	wget -O $@.tmp "https://cloud-images.ubuntu.com/hirsute/current/hirsute-server-cloudimg-ppc64el.img"
	mv $@.tmp $@
	chmod a-w $@
	sha256sum $@ > $@.sum

cloud-init-user-data.img: cloud-init-user-data.txt
	cloud-localds $@ $<

clean:
	@echo "Use distclean to remove rootfs images"

distclean:
	rm -f $(IMAGES)

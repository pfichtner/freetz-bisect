# freetz-bisect

![image 1](https://pfichtner.github.io/freetz-bisect/IMG_20220109_124304362.jpg)
![image 2](https://pfichtner.github.io/freetz-bisect/IMG_20220109_124311409.jpg)
![video 1](https://pfichtner.github.io/freetz-bisect/VID_20220109_124042858.mp4)
![video 2](https://pfichtner.github.io/freetz-bisect/VID_20220109_125347238.mp4)

```
docker run \
--net=host --privileged \ # to access /dev/ttyUSBx
--rm -it \
--user 0 \ # to run apt install (missing tools for push_firmware
--entrypoint "" \
-v $PWD:/workspace # not needed, here resists my git checkout which I do copy using "cp -aT /workspace /freetz" inside the container to have a freetz checkout
-v $PWD/dl:/freetz/dl \ # share download directory
IMAGE=pfichtner/freetz \
/bin/bash
```

# cp .config and bisect.sh to container (docker cp <local file> <container-id>:/)

# as root
```
apt update
apt install mosquitto-clients screen iproute2 ncftp iputils-ping net-tools
ifconfig enx00e04c534458:0 192.168.178.100 up
```

```
su freetz
```

# as freetz

```
umask 0022 ; make menuconfig # configure your needs
cp -ax tools /tmp/ # copy tools (push_firmware changed its syntax during the years, let's use the version from master/main since we use it with current syntax)

git bisect start
git bisect good <SHA of version that is known to work>
git bisect bad <SHA of version that is known not to work>
git bisect run /bisect.sh 
```


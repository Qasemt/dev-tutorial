
# GPIO 

## gpio status 
```
gpioinfo | grep "sysfs"
cat /sys/kernel/debug/gpio

```

## gpio  
```
ls /sys/class/gpio
echo 20 > /sys/class/gpio/export
echo out > /sys/class/gpio/gpio20/direction
echo 1 > /sys/class/gpio/gpio20/value
echo 0 > /sys/class/gpio/gpio20/value

ls /sys/class/gpio
echo 1031 > /sys/class/gpio/export
echo out > /sys/class/gpio/gpio1031/direction
echo 1 > /sys/class/gpio/gpio1031/value
echo 0 > /sys/class/gpio/gpio1031/value

echo 19 > /sys/class/gpio/export
echo out > /sys/class/gpio/gpio19/direction
echo 1 > /sys/class/gpio/gpio19/value
echo 0 > /sys/class/gpio/gpio19/value

echo 2 > /sys/class/gpio/export
echo out > /sys/class/gpio/gpio2/direction
echo 1 > /sys/class/gpio/gpio2/value

echo 8 > /sys/class/gpio/export
echo out > /sys/class/gpio/gpio8/direction
echo 1 > /sys/class/gpio/gpio8/value
echo 0 > /sys/class/gpio/gpio8/value


echo 9 > /sys/class/gpio/export
echo out > /sys/class/gpio/gpio9/direction
echo 1 > /sys/class/gpio/gpio9/value
echo 0 > /sys/class/gpio/gpio9/value


echo 7 > /sys/class/gpio/export
echo out > /sys/class/gpio/gpio7/direction
echo 1 > /sys/class/gpio/gpio7/value
echo 0 > /sys/class/gpio/gpio7/value

```
## gpio lib for python 
```linux
sudo apt install gpiod libgpiod-dev
```

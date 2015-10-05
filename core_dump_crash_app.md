
###### Step 1 :
run this cmd befor run app
```bash
#ulimit -c unlimited
```

###### Step 2 :
run this for tracing
```bash
 gdb <executable> <core-file> or gdb <executable> -c <core-file> or
 ```
 
###### For Exam 
 ```bash
 gdb ./irrigationsysApp -c core
```

# vsomeip-fuzzing_x64
1. Create docker image
```
docker build -t vsomeip_fuzzing_x64 .
```
2. Create container
```
docker run -it -d --name vsomeip_fuzzing_x64 vsomeip_fuzzing_x64
```
3. Enter container
```
docker exec -it vsomeip_fuzzing_x64 /bin/bash
```
4. Begin fuzzing
```
afl-fuzz -i input/ -o output/ -Q ./fuzzing @@
```

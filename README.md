# Shibboleth SP Container

## Generate Keys

### Create certificates/keys for shibboleth, this only needs to be done one time
```
cd docker/shib/
./keygen.sh -n sp-encrypt
./keygen.sh -n sp-signing
cd ../..
```

## Steps to Run

### Delete the container if it exists
```
docker rm -f ubuntu-shib
```

### Build a new image
```
docker build -t ubuntu-shib .
```

### Run a Docker container
Note: replace [my_fqdn] with the public DNS name for the service, for example: www.example.uci.edu
```
docker run -itdp 443:443 -e 'FQDN=[my_fqdn]' --name ubuntu-shib ubuntu-shib
```

### Visit metadata page, download xml file and send to the IAM team to register your SP:
Note: replace [my_fqdn] with the public DNS name for the service
```
https://[my_fqdn]:8443/Shibboleth.sso/Metadata
```
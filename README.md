# knedlsepp.at
This is the configuration for my toy server on AWS and probably utterly useless.

# How-to deploy

```
nixos-rebuild switch --flake .\#knedlsepp-aws --target-host root@knedlsepp.at --build-host root@knedlsepp.at
```

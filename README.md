andrewrothstein.cosign
=========

![Build Status](https://github.com/andrewrothstein/ansible-cosign/actions/workflows/build.yml/badge.svg)

Installs [cosign](https://docs.sigstore.dev/cosign/install).

Requirements
------------

See [meta/main.yml](meta/main.yml)

Role Variables
--------------

See [defaults/main.yml](defaults/main.yml)

Dependencies
------------

See [meta/main.yml](meta/main.yml)

Example Playbook
----------------

```yml
- hosts: servers
  roles:
    - andrewrothstein.cosign
```

License
-------

MIT

Author Information
------------------

Andrew Rothstein <andrew.rothstein@gmail.com>

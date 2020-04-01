Kayobe-Config-Docker
####################

A reference jenkins setup to run kayobe commands from a seed host.

Setting up the environment
--------------------------

The deployment is automated using ``ansible``. To install ansible in a virtual
enviroment you can use the following series of commands:

.. code-block::

    virtualenv venv && source venv/bin/activate
    pip install -U pip
    pip install -r requirements.txt

Next, you must install the ansible roles:

.. code-block::

    ansible-galaxy -r requirements.yml -p roles

You need to make sure your user is in the docker group. For
example, to add the user, ``will``:

.. code-block::

    sudo usermod -a -G docker will
    newgrp docker

You are now ready to perform the configuration.

Configuration
-------------
First add the contents of the `kayobe-docker` directory
to the root of your Kayobe-Config repo like so::
    kayobe_config/
    ├── Dockerfile
    ├── Jenkinsfile
    ├── docker-entrypoint.sh

Don't forget to add and commit the changes to the branch
you wish to deploy. Eventually this will be upstream in
the kayobe_config templates.

Next, edit the contents of ``config.yml`` to suit your environment. 
The file contains all the environment specific configuration and 
has been annotated to explain the function of each variable. To 
generate the encryped variables use a command similar to the following:

.. code-block::

    echo -n 'mums-the-word' | ansible-vault encrypt_string --vault-password-file ~/vaultpassword --stdin-name 'config_as_code_vault_password'

credentials for the ``htpasswd`` file in ``encrypted/htpasswd`` can be generated with:

.. code-block::

    (venv) [will@cumulus-seed kayobe-config-docker]$ ./generate-credentials.sh 
    Jenkins basic auth admin password:
    kmXfSU+3Re8/OIkHb0eQmmAsMqtRr1K8tB37dI2yDxw=
    htpasswd line for admin user:
    admin:$apr1$2NLhaV0V$tskpeMnNZC4KZDadt42zS0

You should encrypt the basic auth admin password and use it as the value of 
``config_as_code_admin_password``. The ``htpasswd`` line can be added to
``encrypted/htpasswd`` as follows:

.. code-block::

    ansible-vault edit encrypted/htpasswd --vault-password ~/vaultpassword

Taking care to remove any old entries. If you don't have the key for the file
you will need to replace it with a new copy:

.. code-block::

    touch encrypted/htpasswd
    ansible-vault encrypt --vault-password ~/vaultpassword encrypted/htpasswd

The file in ``encrypted/id_rsa_jenkins`` was generated with:

.. code-block::

     ssh-keygen -t rsa -b 4096 -f encrypted/id_rsa_jenkins
     ansible-vault encrypt --vault-password ~/vaultpassword encrypted/id_rsa_jenkin

Deploying
---------
Copy or clone this repo (with your changes) onto a Kayobe seed node. 
Proceed with the enviroment and configuration instructions, then run:

.. code-block::

    ansible-playbook deploy.yml --vault-password-file ~/vaultpassword -e@config.yml 

as a user with both sudo and docker privileges. The option given to 
``--vault-password-file`` should contain the password used to encrypt 
the secrets in ``config.yml``

Using the kayobe wrapper script
-------------------------------

This allows you to submit arbitary kayobe commands for jenkins to run via a CLI. 
Optionally, enable bash completion with:

.. code-block::

    (venv) [will@cumulus-seed kayobe-config-docker]$ . <(~/kayobe-env-train/venvs/kayobe/bin/kayobe complete

Next, edit the variables in kayobe-wrapper.sh to suit your environment. Then load the script:

.. code-block::

    . kayobe-wrapper.sh

Set the token:

.. code-block::

    export JENKINS_TOKEN=password

You can then run commands, e.g:

.. code-block::

    (venv) [will@cumulus-seed kayobe-config-docker]$ kayobe network connectivity check 
    Posting: {"parameter": [{"name":"COMMAND", "value":"kayobe network connectivity check"}]} to http://10.60.150.1/job/kayobe-command-run/build

TODO
####

* Support teardown via ansible

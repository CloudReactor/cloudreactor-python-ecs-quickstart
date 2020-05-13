# Secret management

If you followed the quick start guide, you most likely added sensitive 
data to per-environment files, which you don't want to commit in plaintext.
The default configuration assumes you just keep those secret files locally
and don't commit them, thus they are excluded in .gitignore.

However, for sharing with a team or to have the secrets in source control for
backup/history reasons, it's better to check the secret files in, but encrypted. Alternatively, you can get secrets from AWS at runtime.

In this document, we'll cover the management of 2 types of secrets:

* Deployment secrets: these are secrets needed to deploy your task but are not required while the task is running. Examples are AWS access keys/secrets.
In this example project, the files `docker_deploy.env`, 
`docker_deploy.<environment>.yml`, and `deploy/vars/<environment>.yml` contain
deployment secrets.
* Runtime secrets: these are secrets that your task uses while it is running.
Examples are database passwords and API keys for 3rd party services your 
task uses. In this example project, the file `deploy/files/.env.<environment>`
contains runtime secrets. The python tasks read this file at runtime using the 
[python-dotenv](https://github.com/theskumar/python-dotenv) library.

Three methods of managing secrets that we'll cover are:

* Ansible Vault
* git-crypt
* AWS Secrets Manager

### Ansible Vault

One option for managing either deployment or runtime secrets is to use 
[Ansible Vault](https://docs.ansible.com/ansible/latest/user_guide/vault.html)
which is well integrated with ansible. Ansible is used to deploy this
example project, and it will transparently decrypt files encrypted with 
ansible-vault when copying them.

To use ansible-vault to encrypt your deployment secrets, change your directory to /deploy/vars and run:

    ansible-vault encrypt [environment].yml

ansible-vault will prompt for a password, then encrypt the file. To edit it:

    ansible-vault edit [environment].yml

Next, change the deployment script `deploy.sh` to get the encryption password,
either from user input, or an external file or script. Detailed instructions
are in `deploy.sh`. You can also modify `deploy/ansible.cfg` to specify an
external file tha contains the encryption password. See this 
[tutorial](https://www.digitalocean.com/community/tutorials/how-to-use-vault-to-protect-sensitive-ansible-data-on-ubuntu-16-04) for more
details.

You can also use Ansible Vault to encrypt runtime secrets, by following the
steps above for `deploy/files/[environment].yml`. However, this has the 
drawback that the secrets will be in plaintext in your container image.
For most applications, that is secure enough because [AWS ECR stores images
encrypted](https://aws.amazon.com/ecr/faqs/) and it is assumed the server
you deploy from (which builds and caches Docker images) is secure.

Once you figure out which files to encrypte, uncomment the lines in 
`.gitignore` that ignore secret files, since you'll be checking them in encrypted.

### git-crypt

Another option for encryption is 
[git crypt](https://github.com/AGWA/git-crypt), 
which encrypt secrets when they are committed to Git. 
However, this leaves secrets unencrypted in the filesystem where the 
repository is checked out. That can be advantage as it is easier
to edit and search secret files.

If you set up git-crypt, uncomment the lines in `.gitignore` that ignore 
secret files, since they will be encrypted in the repository.

The disadvantage of using git-crypt is that if the machine or disk that
contains these secret files is compromised, those secrets can be exposed. 

## Runtime secrets

As a best practice, runtime secrets should not be present in the
Docker images. Instead you can use AWS Secrets Manager to set environment
variables that the tasks can read during runtime. To do that, add a 
`secrets` section to the `extra_task_definition_properties`, like this:

    task_name_to_config:
        some_task:
            command: "python main.py"
            # ... other properties here
            ecs:
               # ... other properties here
               extra_task_definition_properties:
                 secrets:
                   -name: SOME_SECRET_NAME
                    valueFrom: "arn:aws:ssm:<region>:<aws_account_id>:parameter/parameter_name"

See `deploy/common.yml` for an example on how to do that.


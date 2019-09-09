# jenkins-configuration-as-code-pipeline-linter

Lint Jenkinsfile using locally owned Jenkins instance.

## Prerequisites

- Docker Compose

## Getting Started

- Clone this repository.
- Create `jenkins_admin_password` file with desired password for `voltron` administrator account.
- Run the `lint.sh` script with required arguments.

```bash
./lint.sh \
    --file=${PWD}/example/Jenkinsfile
```

## License

[GNU General Public License v3.0](LICENSE)

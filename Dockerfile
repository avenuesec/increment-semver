FROM bitnami/git:latest

LABEL "com.github.actions.name"="Increment Semver"
LABEL "com.github.actions.description"="Get the next version of a github repository"
LABEL "com.github.actions.icon"="git-commit"
LABEL "com.github.actions.color"="grey"

LABEL "repository"="https://github.com/Benbentwo/increment-semver"
LABEL "homepage"="https://github.com/Benbentwo/increment-semver"

ADD entrypoint.sh /
RUN chmod +x /entrypoint.sh

USER 1000

ENTRYPOINT ["/entrypoint.sh"]

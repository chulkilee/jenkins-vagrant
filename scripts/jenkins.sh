#!/bin/bash -eux
fqdn=`hostname -f`
plugins=( depgraph-view git )

################################################################################
# jenkins
################################################################################

apt-get -qq -y install curl

curl -s http://pkg.jenkins-ci.org/debian/jenkins-ci.org.key | apt-key add -
echo 'deb http://pkg.jenkins-ci.org/debian binary/' > /etc/apt/sources.list.d/jenkins.list

apt-get -qq -y update
apt-get -qq -y install jenkins ttf-dejavu \
    graphviz

################################################################################
# nginx
################################################################################

apt-get -qq -y install nginx

echo "upstream jenkins {
    server 127.0.0.1:8080 fail_timeout=0;
}
server {
    listen 80;
    server_name ${fqdn} default;

    location / {
        proxy_set_header Host \$http_host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_redirect off;

        if (!-f \$request_filename) {
            proxy_pass http://jenkins;
            break;
        }
    }
}
" > /etc/nginx/sites-available/jenkins

ln -s -f /etc/nginx/sites-available/jenkins /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default

service nginx restart

# wait for jenkins started
sleep 60

################################################################################
# jenkins plugins
################################################################################

jenkins_url=http://${fqdn}
jenkins_cli="java -jar jenkins-cli.jar -s ${jenkins_url}"

pushd /tmp
    curl -s $jenkins_url/jnlpJars/jenkins-cli.jar -o jenkins-cli.jar

    # https://gist.github.com/jedi4ever/898114
    curl -s -L http://updates.jenkins-ci.org/update-center.json | sed '1d;$d' | curl -X POST -H 'Accept: application/json' -d @- ${jenkins_url}/updateCenter/byId/default/postBack

    for plugin in "${plugins[@]}"; do
      ${jenkins_cli} install-plugin ${plugin}
    done
    ${jenkins_cli} safe-restart
popd

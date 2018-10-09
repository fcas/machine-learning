FROM jeff1evesque/ml-base:0.8

## local variables
ENV ENVIRONMENT=docker\
    ROOT_PROJECT=/var/machine-learning\
    PUPPET=/opt/puppetlabs/bin/puppet\
    ROOT_PUPPET=/etc/puppetlabs
ENV MODULES=$ROOT_PUPPET/code/modules\
    CONTRIB_MODULES=$ROOT_PUPPET/code/modules_contrib

ARG TYPE
ARG VHOST
ARG HOST_PORT
ARG LISTEN_PORT
ARG MEMBERS

## copy files into container
COPY hiera.yaml $ROOT_PUPPET/puppet/hiera.yaml
COPY hiera/reverse-proxy/nginx-$TYPE.yaml $ROOT_PUPPET/puppet/hiera/reverse-proxy/nginx.yaml
COPY puppet/environment/$ENVIRONMENT/modules/reverse_proxy $ROOT_PUPPET/code/modules/reverse_proxy

##
## provision with puppet: either build a web, or api nginx image.
##
##     docker build --build-arg TYPE=api --build-arg RUN=false --build-arg VHOST=machine-learning-api.com --build-arg LISTEN_PORT=6000 -f nginx.dockerfile -t jeff1evesque/ml-nginx-api:0.8 .
##     docker build --build-arg TYPE=web --build-arg RUN=false --build-arg VHOST=machine-learning-web.com --build-arg LISTEN_PORT=5000 -f nginx.dockerfile -t jeff1evesque/ml-nginx-web:0.8 .
##
##     docker build --build-arg TYPE=api --build-arg RUN=false -f nginx.dockerfile -t jeff1evesque/ml-nginx-api:0.8 .
##     docker build --build-arg TYPE=web --build-arg RUN=false -f nginx.dockerfile -t jeff1evesque/ml-nginx-web:0.8 .
##
##     docker run --hostname nginx-api --name nginx-api -d jeff1evesque/ml-nginx-api:0.8
##     docker run --hostname nginx-web --name nginx-web -d jeff1evesque/ml-nginx-web:0.8
##
RUN $PUPPET apply -e "class { reverse_proxy: \
    run => 'false', \
} " --modulepath=$CONTRIB_MODULES:$MODULES --confdir=$ROOT_PUPPET/puppet

## start nginx
CMD ["nginx", "-g", "daemon off;"]

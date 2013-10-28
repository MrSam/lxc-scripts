lxc-scripts
===========

Scripts to manage my lxc containers.

The general idea is that you create one template container that then can be cloned 
when creating new ones. This template name should be placed in the variable LXC_TEMPLATE_NAME.

The host server runs a NGINX that is used to forward the correct hostnames
to the right container. For this to work you need to set up a wildcard DNS domain
and point it to the host. This DNS domain should be placed in the variable DOMAIN_SUFFIX.

A pretty cool feature is a script that i found on Github .. update_all_containers.sh 
This will run over all your (debian based) containers and apt-get update them.

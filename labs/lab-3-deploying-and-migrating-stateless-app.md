## Deploying and Migrating a Stateless App

### Adding or Removing Remote Nodes or Default Region Nodes

1. Deploy Marathon-lb on AWS

1. Run `terraform output` and locate you AWS Public Agent ELB name. For example:

```bash
Public Agent ELB Address = alexly-tf78ff-pub-agt-elb-1172026073.us-east-1.elb.amazonaws.com
```

2. Copy your ELB name and place it in your _dcos-website.json_ in the `HAPROXY_0_VHOST` value. 



```bash 
{
  "id": "dcos-website",
  "container": {
    "type": "DOCKER",
    "docker": {
      "image": "mesosphere/dcos-website:cff383e4f5a51bf04e2d0177c5023e7cebcab3cc",
      "network": "BRIDGE",
      "portMappings": [
        { "hostPort": 0, "containerPort": 80, "servicePort": 10004 }
      ]
    }
  },
  "instances": 3,
  "cpus": 0.25,
  "mem": 100,
  "healthChecks": [{
      "protocol": "HTTP",
      "path": "/",
      "portIndex": 0,
      "timeoutSeconds": 2,
      "gracePeriodSeconds": 15,
      "intervalSeconds": 3,
      "maxConsecutiveFailures": 2
  }],
  "labels":{
    "HAPROXY_DEPLOYMENT_GROUP":"dcos-website",
    "HAPROXY_DEPLOYMENT_ALT_PORT":"10005",
    "HAPROXY_GROUP":"external",
    "HAPROXY_0_REDIRECT_TO_HTTPS":"true"
    "HAPROXY_0_VHOST":"<INSERT_ELB_NAME_FROM_TERRAFORM_OUTPUT_BY_CLOUD_PROVIDER>"
  }
}
```

3. Deploy the application using the json editor on DC/OS UI or using the DC/OS CLI. 
 
Because we haven't decided which region by default it will be automatically deployed on the local region which is AWS. 

4. Ensure you can reach your application from the web via the ELB name on your broswer. This will ensure that your application is successfully running on AWS.

5. Go to the Services tab on the DC/OS website and edit the configuration and edit your dcos-website and go to the placement tab and change the default region from local to Azure. Apply changes and validate that the application gets redeployed to Azure.

6. Check that you can still see the application still running on the same AWS ELB address.


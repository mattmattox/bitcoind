# Docker Container
The bitcoin docker container can be built and pushed using the following commands:

```bash
$ docker build . -t azamatms/bitcoind
$ docker push azamatms/bitcoind
```

It should download the bitcoind coin-daemon source code, set up the dependencies, compile the daemon, and set the entrypoint.

If the compiling stage fails, the docker build should terminate with a non-zero exit status.

To check if the compiled daemon is functioning, run the container locally.

```bash
$ docker run -ti azamatms/bitcoind
2018-06-20T15:25:23Z Bitcoin Core version v0.16.99.0-4a7e64fc8 (release build)
2018-06-20T15:25:23Z InitParameterInteraction: parameter interaction: -whitelistforcerelay=1 -> setting -whitelistrelay=1
2018-06-20T15:25:23Z Assuming ancestors of block 0000000000000000005214481d2d96f898e3d5416e43359c145944a909d242e0 have valid signatures.
2018-06-20T15:25:23Z Setting nMinimumChainWork=000000000000000000000000000000000000000000f91c579d57cad4bc5278cc
2018-06-20T15:25:23Z Using the 'sse4(1way+4way),avx2(8way)' SHA256 implementation
2018-06-20T15:25:23Z Using RdRand as an additional entropy source
2018-06-20T15:25:23Z Default data directory /root/.bitcoin
...
```

# Standard Deployment

An ansible playbook (`playbook.yml`) has been made to deploy the coin daemon container.

The host based deployment can be tested using Virtualbox and Vagrant, run `vagrant up`.

In order to automate the AWS infrastucture provisioning we will use Terraform, a `terraform.tf` file has been provided for this.

Example:

```bash
$ terraform init
Initializing provider plugins...

...

$ terraform apply
var.vpc_id
  Enter a value: vpc-308e3149

data.template_file.userdata: Refreshing state...
data.aws_vpc.vpc: Refreshing state...
data.aws_subnet_ids.subnets: Refreshing state...
data.aws_ami.ubuntu: Refreshing state...

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  + aws_autoscaling_group.bitcoind
      id:                             <computed>
      arn:                            <computed>
      default_cooldown:               <computed>
      desired_capacity:               <computed>
      force_delete:                   "false"
      health_check_grace_period:      "300"
      health_check_type:              <computed>
      launch_configuration:           "${aws_launch_configuration.daemon_lc.id}"
      load_balancers.#:               <computed>
      max_size:                       "5"
      metrics_granularity:            "1Minute"
      min_size:                       "2"
      name:                           <computed>
      name_prefix:                    "bitoind-"
      protect_from_scale_in:          "false"
      service_linked_role_arn:        <computed>
      target_group_arns.#:            <computed>
      vpc_zone_identifier.#:          "4"
      vpc_zone_identifier.1252594634: "subnet-f2b1a497"
      vpc_zone_identifier.3662836120: "subnet-16992e4c"
      vpc_zone_identifier.607228002:  "subnet-f59324af"
      vpc_zone_identifier.874127514:  "subnet-8cbca9e9"
      wait_for_capacity_timeout:      "10m"

  + aws_launch_configuration.daemon_lc
      id:                             <computed>
      associate_public_ip_address:    "true"
      ebs_block_device.#:             <computed>
      ebs_optimized:                  <computed>
      enable_monitoring:              "true"
      image_id:                       "ami-a4dc46db"
      instance_type:                  "t2.large"
      key_name:                       <computed>
      name:                           <computed>
      name_prefix:                    "bitoind-"
      root_block_device.#:            <computed>
      user_data:                      "168eaa92f9d203d6a9331e20ea004c82da9e6751"


Plan: 2 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

aws_launch_configuration.daemon_lc: Creating...
  associate_public_ip_address: "" => "true"
  ebs_block_device.#:          "" => "<computed>"
  ebs_optimized:               "" => "<computed>"
  enable_monitoring:           "" => "true"
  image_id:                    "" => "ami-a4dc46db"
  instance_type:               "" => "t2.large"
  key_name:                    "" => "<computed>"
...
```




# Kubernetes Statefulset

There are kubernetes manifest files available for a more container centric deployment in the `k8s` directory.

### EBS Volumes on AWS
`k8s/statefulSetAws.yml` contains a version of the statefulset which mounts EBS volumes for the blockchain data.

This allows any failed coin daemon to restart on the same node with the same data it had before.
On average, it takes 3-4 hours for a daemon to spool up the initial blockchain data.

Example:
```bash
$ minikube start
Starting local Kubernetes v1.10.0 cluster...
Starting VM...
Getting VM IP address...
Moving files into cluster...
Setting up certs...
Connecting to cluster...
Setting up kubeconfig...
Starting cluster components...
Kubectl is now configured to use the cluster.
Loading cached images from config file.

$ kubectl apply -f k8s/statefulSet.yml
statefulset.apps "bitcoind" created

$ kubectl get pods
NAME         READY     STATUS    RESTARTS   AGE
bitcoind-0   1/1       Running   0          2m
```

### Scaling

The statefulset only has one replica. You can scale it using the command below, you will need a cluster with more than one node for this.

```bash
$ kubectl scale sts bitcoind --replicas 3
statefulset.apps "bitcoind" scaled
```

            =============================
              IOT - Intro to Kubernetes
            =============================

-----------
OBJECTIVES: To use K3s et K3s with Vagrant
-----------
- To set up a personnal VM with Vagrant and the distribution of our choice
- To know how to use K3s and its Ingress
- To discover K3d

-----
PARTS
-----
- P1: K3s and Vagrant
- P2: K3s and 3 simple applications
- P3: K3d and Argo CD


-------------------------
DOCUMENTATION & RESOURCES
-------------------------
- K8s: 
https://kubernetes.io/
- K3s: 
https://k3s.io/
- K3d: 
https://k3d.io/stable/

- Kubernetes:
https://kubernetes.io/docs/home/
- Tuto: 
https://kubernetes.io/docs/concepts/
- Cluster Architecture  (Cf. illustration): 
https://kubernetes.io/docs/concepts/architecture/

- Vagrantfile: 
https://developer.hashicorp.com/vagrant/docs/vagrantfile
- K3s CLI Tools:
https://docs.k3s.io/cli

- [YT] Cours K8s: 
https://www.youtube.com/watch?v=2T86xAtR6Fo
- [YT] Intro to K3s Online Training: 
https://www.youtube.com/watch?v=vRjk3r9fwFo


-----------
DEFINITIONS
-----------

*******************************************************************
More definitions here (Overview, Cluster Architecture, Containers, Workloads, Policies, Services, Load Balancing and Networking, Cluster Administartion, etc.):
=> https://kubernetes.io/docs/concepts/
*******************************************************************

- Vagrant:
Vagrant is an open-source software product developed by HashiCorp for building and maintaining portable virtual software development environments. It provides a simple and easy-to-use command-line client for managing virtualized development environments. 
Vagrant can create, configure, and manage virtual machines using providers like VirtualBox, VMware, Hyper-V, and Docker.

- Ingress:
In Kubernetes, an Ingress is an API object that manages external access to services in a cluster, typically HTTP/HTTPS.
Ingress is a powerful tool for managing external access to services in a Kubernetes cluster, providing flexibility and control over how traffic is routed and handled.

- Argo CD:
Argo CD is a declarative, GitOps continuous delivery tool for Kubernetes. It is designed to help manage and deploy applications on Kubernetes clusters by using Git repositories as the source of truth for defining the desired application state.


********************************************************
- Docker vs Kubernetes
********************************************************

Docker is primarily focused on the creation, management, and running of individual containers. It is often used for development and deployment of containerized applications.

Kubernetes is focused on the orchestration and management of containerized applications at scale. It is used to manage clusters of containers, ensuring high availability, scalability, and self-healing capabilities.

In many environments, Docker and Kubernetes are used together. Docker is used to build and manage container images, while Kubernetes is used to orchestrate and manage the deployment of those containers in a production environment.


********************************************************
- k8s vs k3s vs k3d  (Cf. illustration)
********************************************************

k8s (Kubernetes): 
=================

Kubernetes is an open source container orchestration engine for automating deployment, scaling, and management of containerized applications. The open source project is hosted by the Cloud Native Computing Foundation (CNCF).

Kubernetes is a portable, extensible, open source platform for managing containerized workloads and services, that facilitates both declarative configuration and automation. It has a large, rapidly growing ecosystem. Kubernetes services, support, and tools are widely available.

* Container Orchestration: Manages the lifecycle of containerized applications.
* Scalability: Automatically scales applications based on demand.
* Self-Healing: Automatically restarts failed containers, replaces containers, and kills containers that don't respond to user-defined health checks.
* Load Balancing and Service Discovery: Distributes network traffic to ensure stable and reliable deployments.
* Declarative Configuration: Uses declarative configuration files to define the desired state of applications and infrastructure.
* Extensibility: Supports a wide range of plugins and extensions to enhance functionality


k3s [Rancher Labs]:
=====================

K3s is a lightweight Kubernetes distribution developed by Rancher Labs. It is designed to be easy to install, with minimal dependencies, and optimized for resource-constrained environments such as edge computing, IoT devices, and development environments.
* Lightweight: Reduced resource footprint compared to standard Kubernetes.

* Simplified Installation: Single binary installation with minimal dependencies.
* SQLite Integration: Uses SQLite as the default storage backend, reducing the need for etcd.
* Optimized for Edge: Suitable for edge computing and IoT devices.
* Compatibility: Fully compatible with standard Kubernetes, allowing the use of existing Kubernetes tools and configurations.


k3d [Rancher Labs]:
===================

K3d is a lightweight wrapper around k3s in Docker developed by Rancher Labs. It is designed to run K3s clusters in Docker containers, making it easy to create and manage local Kubernetes clusters for development and testing purposes.

* Docker Integration: Runs K3s clusters in Docker containers.
* Easy Setup: Simplifies the process of creating and managing local Kubernetes clusters.
* Lightweight: Optimized for local development and testing environments.
* Compatibility: Fully compatible with K3s and standard Kubernetes, allowing the use of existing Kubernetes tools and configurations.


********************************************************
- Control Plane vs Data Plane (Cf. illustration)
********************************************************

Control Plane: Components
=========================

The control plane in Kubernetes is the set of components that manage and control the cluster. It makes global decisions about the cluster (e.g., scheduling) and detects and responds to cluster events (e.g., starting up a new pod when a deployment's replicas field is unsatisfied).

Key Components:
~~~~~~~~~~~~~~~
- kube-apiserver: Exposes the Kubernetes API, which is used by the command-line interface (kubectl) and other tools to interact with the cluster.
- etcd: A consistent and highly available key-value store used as Kubernetes' backing store for all cluster data.
- kube-scheduler: Watches for newly created pods that have no assigned node and selects a node for them to run on.
- kube-controller-manager: Runs controllers, which are background threads that handle routine tasks in the cluster. Examples include the Node Controller, Replication Controller, and Deployments.
- cloud-controller-manager: Links your cluster into your cloud provider's API and separates out the components that interact with that cloud platform from components that only interact with your cluster.

Key Functions:
~~~~~~~~~~~~~~
- Cluster Management: Manages the overall state of the cluster, including scheduling, scaling, and maintaining the desired state of applications.
- API Exposure: Provides the Kubernetes API for interacting with the cluster.
- Data Storage: Stores cluster state and configuration data in etcd.
- Controller Operations: Runs various controllers to handle routine tasks and maintain the desired state of the cluster.


Data Plane: Apps
================

The data plane in Kubernetes consists of the components that run the actual workloads (containers) and handle the networking and storage for those workloads. It is responsible for executing the decisions made by the control plane.

Key Components:
~~~~~~~~~~~~~~~
- kubelet: An agent that runs on each node in the cluster. It ensures that containers are running in a pod and communicates with the control plane.
- kube-proxy: A network proxy that runs on each node in the cluster. It maintains network rules on nodes and performs connection forwarding.
- Container Runtime: The software that is responsible for running containers (e.g., Docker, containerd).
- Nodes: The worker machines in Kubernetes, which can be either physical or virtual machines. Nodes run the pods that contain the application workloads.

Key Functions:
~~~~~~~~~~~~~~
- Pod Management: Ensures that containers are running in pods and communicates with the control plane.
- Networking: Manages network rules and performs connection forwarding to enable communication between pods and services.
- Container Execution: Runs the containers that make up the application workloads.
- Resource Management: Manages the resources (CPU, memory, storage) allocated to pods and containers.


------------
INSTALLATION
------------

# --- k3s ---

    // INSTALLATION
sudo apt update && sudo apt upgrade -y
curl -sfL https://get.k3s.io | sh -

    // STATUS VERIFICATION
sudo kubectl get nodes

    // ACCESSING K8S CLUSTER
mkdir -p ~/.kube
sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
sudo chown $(id -u):$(id -g) ~/.kube/config

    // OPTIONS
curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION=v1.21.3+k3s1 sh -s - --write-kubeconfig-mode 644

    // UNINSTALL
sudo /usr/local/bin/k3s-uninstall.sh

    // GET STARTED
sudo k3s server &
* Kubeconfig is written to /etc/rancher/k3s/k3s.yaml
sudo k3s kubectl get node
* On a different node run the below command. 
* NODE_TOKEN comes from /var/lib/rancher/k3s/server/node-token on your server
sudo k3s agent --server https://myserver:6443 --token ${NODE_TOKEN}
-----------------------------------------------------------------------

# --- Pre ---
Use VM
Modify settings: 2 boxes to check
Install virtualbox


# --- Vagrant ---
    // INSTALLATION
wget https://releases.hashicorp.com/vagrant/2.4.6/vagrant_2.4.6-1_amd64.deb
sudo apt install ./vagrant_2.4.6-1_amd64.deb

    // COMMANDS
vagrant init
vagrant up
vagrant status
vagrant halt
vagrant destroy
- To access the VM -
    vagrant ssh aderouinS
    vagrant ssh aderouinSW


////
Wait for K3s to finish initializing
K3s runs asynchronously after installation. So immediately accessing /etc/rancher/k3s/k3s.yaml or /var/lib/rancher/k3s/server/node-token often fails.

➡️ Add a wait loop in your provision script to ensure K3s finishes booting:
////

///////////////////////////////////////////////////////////////////
/// MANDATORY             ////////////////////////////////////////
///////////////////////////////////////////////////////////////////

==========
  PART 1
==========

-------
SUBJECT
-------
- 2 machines
- Vagrantfile (latest stable version | distribution of our choice [OS] | to set up according "modern practices")
- resources: 1 CPU | 512MB RAM (or 1024MB)
- expected specs:
    * 1st machine = {login}S  = aderouinS   // S = Server
    * aderouinS (eth1) = 192.168.56.110
    * K3s installed on it in CONTROLLER MODE
    
    * 2nd machine = {login}SW = aderouinSW  // SW = ServerWorker
    * aderouinSW (eth1) = 192.168.56.111
    * K3s installed on it in AGENT MODE
        
    * can connect to both machine with SSH [no password]
    
    * have to use kubectl, so install it


--------
COMMANDS
--------



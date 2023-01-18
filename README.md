## Configuration

### Cluster

The configuration above assumes that the k8s namespace `mina-testnet` will be
used to install the helmchart. Also it specifies that the user `build-bot` will
perform the installation.

To create the namespace, use the following command:

``` sh
kubectl create namespace mina-testnet
```

To configure a _service account_ `build-bot`, that is restricted only to the
`mina-testnet` namespace, you need to do the following.

Create the service account:

``` sh
kubectl create --namespace mina-testnet serviceaccount build-bot
```

Create a file defining a role that allows installation using helm:

``` yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: helm-role
rules:
- apiGroups:
  - ""
  - batch
  - extensions
  - apps
  resources:
  - '*'
  verbs:
  - '*'
```

Now create the k8s resource from this file (assuming it is `helm-role.yaml`):

``` sh
kubectl apply -f helm-role.yaml
```

Or, with a single command:

``` sh
kubectl create -f - <<EOF
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: helm-role
rules:
- apiGroups:
  - ""
  - batch
  - extensions
  - apps
  resources:
  - '*'
  verbs:
  - '*'
EOF
```

Then, assign the role to the account by creating a role binding:

``` sh
kubectl create rolebinding build-bot-binding --role=helm-role --serviceaccount=mina-testnet:build-bot
```

And finally, create a token for the service account, to be specified in the
configuration above (the token will last for 10000 hours (~400 days)):

``` sh
kubectl create token --duration=1000h build-bot
```

### Github Repository

Kubernetes configuration should be specified using a secret with name
`KUBECONFIG`. Below is the template for the Openmina private cluster:

``` yaml
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUMvakNDQWVhZ0F3SUJBZ0lCQURBTkJna3Foa2lHOXcwQkFRc0ZBREFWTVJNd0VRWURWUVFERXdwcmRXSmwKY201bGRHVnpNQjRYRFRJeU1URXlPVEV4TlRRek5Wb1hEVE15TVRFeU5qRXhOVFF6TlZvd0ZURVRNQkVHQTFVRQpBeE1LYTNWaVpYSnVaWFJsY3pDQ0FTSXdEUVlKS29aSWh2Y05BUUVCQlFBRGdnRVBBRENDQVFvQ2dnRUJBTTZnCldpbzhVM2kza2RqNXd4Skk3VWwvZ2dXRU0wdG42a2VoT0l5c1BXRmg0TXMzL0kwYko2THBmNk1WZGlsdkhDZUcKeU5yelRtcHpCMUJuUWRkWEdNRkE1eTVCMVZqOW5mZDZUN0ZIUmd1Ri96ZXA3TTZuMWZNbVpjL3dzY3VndmUwQwpnRWgxU3ZaUFFRMGYwdjFuRHhQNU05Z2FMTU1SYlNNQ0xuZFlIZDViMlh5NjVoeEI3ejFwdUZPY1NxQTh2S3pQCnI0TFFZbVlSYkM1SlVick5CVStMSXJzamp4SVg3d25XTS90MC93d0hoTTlpeFY4NVA4QnFOZVBPc0UzM2g0UlAKdnl4UDRvSUdVQ2xBSDgzYVlTVHpuWncvalJHV1YxcjRYTlRidVBRdllFVVYwbTNLMDltQllnRFlKdkg3dy9ybAp5N1ZzaksxUEVtNmd4QWFkbkxNQ0F3RUFBYU5aTUZjd0RnWURWUjBQQVFIL0JBUURBZ0trTUE4R0ExVWRFd0VCCi93UUZNQU1CQWY4d0hRWURWUjBPQkJZRUZJQUk1WEtZMkt4R3pPWU5aWmh6S1JicUZnRmVNQlVHQTFVZEVRUU8KTUF5Q0NtdDFZbVZ5Ym1WMFpYTXdEUVlKS29aSWh2Y05BUUVMQlFBRGdnRUJBTXpkYU1qMDlJaXJuWit1MzNWYwo1UWlabG5nU0k5eXlydGtITDR1dkJ4QUdMaWpOYitrWGd0blhRSU96SkZIR2NYQkV3UnFPbVF0YlZEaUdCK3dpCjU1RFhaY0wzMWFtTS8yNEpLTnZBVkZUV3p3cFVzVmg3ZGphWDhxVWU0R1FzUDZHcWtCSFVtb1htSXV4cTZZRDIKRHBGdE9mRWlyRmxJMnlkczhhUHFXZHlNTi9DNnBjcWxjNi84d1QxaG9rUmROWEFJaWg4MXJmb3hOTGhVQmVJMgp4YytqMkdjc3hJMUk3bUl2OFBra2t0Yks1Z3RFWG1tcHJ1TnBhV0JzSVRXazIxVjMxUEhrSWtYOGw0amNkQm4rClRkZzFKRHVUNXJiVjBDcE12d2hjdkNvWW1iVXh5T21Pd1ljb1QyQjkyQ0NqbmtHWW9FelhyeTV0Qzd3K1RXMUkKU2VFPQotLS0tLUVORCBDRVJUSUZJQ0FURS0tLS0tCg==
    server: https://135.181.217.23:6443
  name: hetzner
contexts:
- context:
    cluster: hetzner
    namespace: mina-testnet
    user: build-bot
  name: hetzner
current-context: hetzner
kind: Config
preferences: {}
users:
- name: build-bot
  user:
    token: ***
```

### Seed Nodes

In order to specify a seed node, add an entry in `seedConfigs` list value:

``` yaml
seedConfigs:
  - name: seed1
    libp2pSecret: seed1-libp2p-secret
```

The secret `seed1-libp2p-secret` should contain public and private keys of the
libp2p peer that the node will impersonate. To create this secret from existing
files, use the following command:

``` sh
kubectl create secret generic seed1-libp2p-secret --from-file=key=resources/seed1 --from-file=pub=resources/seed1.peerid
```

### Producer Node 

Each producer is configured by an element in the `blockProducerConfigs` list
value:

``` yaml
blockProducerConfigs:
  - name: prod1
    privateKeySecret: prod1-privkey-secret
    isolated: false
```

The secret `prod1-privkey-secret` should contain public and private keys of the
Mina account that the node will use to produce blocks. To create this secret
from existing files, use the following command:

``` sh
kubectl create secret generic prod1-privkey-secret --from-file=key=resources/key-01 --from-file=pub=resources/key-01.pub
```


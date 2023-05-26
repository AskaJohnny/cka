# this is script for creating exam env make sure you run it with root privilege
# created and maintained by Simon Yang from 99cloud
# clean up
rm ~/task*.* -f
rm ~/tmep*.* -f
kubectl delete pod -n task13-namespace --all
kubectl delete pod -n task18-ns --all
kubectl delete ns task9-ns-quota
kubectl delete ns task18-ns
kubectl delete ns task13-namespace
kubectl delete resourcequotas quota-demo
kubectl delete secrets mysecret
kubectl taint node k8smaster mykey- # depending on the key name you named when u taint the node
kubectl delete deployment --all 
kubectl delete svc --all
kubectl delete svc -n task18-ns --all
kubectl delete pvc --all
kubectl delete pv --all
kubectl delete ds --all
kubectl delete pod --all
kubectl label pod -n kube-system --all mesureable-
rm -rf /tmp/workingdir
rm -rf /tmp/data
mkdir -p /tmp/data/pv1
mkdir -p /tmp/data/pv2
mkdir -p /tmp/data/pv3
mkdir -p /tmp/workingdir
rm -rf /opt/answers
mkdir /opt/answers
rm -rf /opt/templates

echo 'sleep 20s 4 k8s to delete existing pod'
sleep 20

# create pre

mkdir /opt/templates
kubectl run task-6-deploy --image=nginx:1.16.1 --image-pull-policy=IfNotPresent --replicas=2 --record=true
kubectl label pod -n kube-system --all mesureable=true
kubectl create ns task9-ns-quota
kubectl create ns task18-ns
cat <<EOF | kubectl create --namespace=task9-ns-quota -f  -
apiVersion: v1
kind: ResourceQuota
metadata:
  name: quota-demo
spec:
  hard:
    limits.cpu: "1"
    limits.memory: 1Gi
    pods: "3"
EOF



cat <<EOF | kubectl create -f -
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv01
spec:
  capacity:
    storage: 5Gi
  volumeMode: Filesystem
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Recycle
  storageClassName: slow
  hostPath:
    path: /tmp/data/pv1

---

apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv02
spec:
  capacity:
    storage: 2Gi
  volumeMode: Filesystem
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Recycle
  storageClassName: slow
  hostPath:
    path: /tmp/data/pv2

---

apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv03
spec:
  capacity:
    storage: 15Gi
  volumeMode: Filesystem
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Recycle
  storageClassName: slow
  hostPath:
    path: /tmp/data/pv3

---

apiVersion: v1
kind: Pod
metadata:
  name: task0-pod-log
spec:
  containers:
  - name: task0-pod-log-nginx
    image: nginx:1.16.1
    imagePullPolicy: IfNotPresent
    command: [ "/bin/sh", "-c", "echo 'file not found\n check the local directory ensure the directory is ready'"]
    volumeMounts:
    - mountPath: /workingdir
      name: workingdir
  volumes:
    - name: workingdir
      hostPath:
        path: /tmp/workingdir
        type: Directory

---

apiVersion: v1
kind: Pod
metadata:
  name: task8-pod
  labels:
    app: task8-pod
spec:
  containers:
  - name: task8-container
    image: nginx:1.16.1
    imagePullPolicy: IfNotPresent
    ports:
    - containerPort: 80

---

apiVersion: v1
kind: Pod
metadata:
  name: task9-pod1
  namespace: task9-ns-quota
  labels:
    task9: app1
spec:
  containers:
  - name: task9-pod1-ctr
    image: nginx:1.16.1
    imagePullPolicy: IfNotPresent
    resources:
      limits:
        memory: "300Mi"
        cpu: "300m"
      requests:
        memory: "200Mi"
        cpu: "200m"

---

apiVersion: v1
kind: Pod
metadata:
  name: task9-pod2
  namespace: task9-ns-quota
  labels:
    task9: app1
spec:
  containers:
  - name: task9-pod2-ctr
    image: postgres:9.4
    imagePullPolicy: IfNotPresent
    resources:
      limits:
        memory: "500Mi"
        cpu: "500m"
      requests:
        memory: "300Mi"
        cpu: "300m"

---

apiVersion: v1
kind: Pod
metadata:
  name: task9-pod3
  namespace: task9-ns-quota
  labels:
    task9: app2
spec:
  containers:
  - name: task9-pod3-ctr
    image: nginx:1.16.1
    imagePullPolicy: IfNotPresent
    resources:
      limits:
        memory: "200Mi"
        cpu: "200m"
      requests:
        memory: "100Mi"
        cpu: "100m"

---

apiVersion: v1
kind: Pod
metadata:
  name: task18-pod1
  namespace: task18-ns
  labels:
    app1: task18-app1
spec:
  containers:
  - name: task8-container
    image: nginx:1.16.1
    imagePullPolicy: IfNotPresent
    ports:
    - containerPort: 80

---

apiVersion: v1
kind: Pod
metadata:
  name: task18-pod2
  namespace: task18-ns
  labels:
    app2: task18-app2
spec:
  containers:
  - name: task8-container
    image: nginx:1.16.1
    imagePullPolicy: IfNotPresent
    ports:
    - containerPort: 80

---

apiVersion: v1
kind: Pod
metadata:
  name: task18-pod3
  namespace: task18-ns
  labels:
    app3: task18-app3
spec:
  containers:
  - name: task8-container
    image: nginx:1.16.1
    imagePullPolicy: IfNotPresent
    ports:
    - containerPort: 80

---

kind: Service
apiVersion: v1
metadata:
  name: task18-service
  namespace: task18-ns
spec:
  selector:
    app3: task18-app3
  ports:
  - protocol: TCP
    port: 80
    targetPort: 80

---

apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: task-24-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 8Gi

EOF

cat <<EOF > /opt/templates/task2-pod-need-fix.yaml
apiVersion: v1
kind: Pod
metadata:
  name: task2-pod-pending
spec:
  containers:
  - name: task2-pod-pending-nginx
    image: nginx:1.16.1
    imagePullPolicy: IfNotPresent
    command: [ "/bin/sh", "-c", "if [ ! -f /workingdir/iwantu.txt ]; then echo 'file not found'; else while :; do echo 'yes. u did it' ; sleep 3; done;fi" ]
    volumeMounts:
    - mountPath: /workingdir
      name: workingdir
  volumes:
    - name: workingdir
      hostPath:
        path: /tmp/workingdir
        type: Directory
EOF
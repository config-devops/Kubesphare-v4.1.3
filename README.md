# Install Kubernetes & Kubespheree

---
# 📦 Dependency Requirements

KubeKey dapat menginstal **Kubernetes** dan **KubeSphere** secara bersamaan.  
Beberapa dependency harus sudah terpasang sebelum instalasi Kubernetes versi ≥ **1.18**.  

Silakan cek tabel berikut untuk memastikan dependensi sudah ada di node kamu:  

| Dependency | Kubernetes Version ≥ 1.18 |
|------------|----------------------------|
| `socat`    | Required                   |
| `conntrack`| Required                   |
| `ebtables` | Optional but recommended   |
| `ipset`    | Optional but recommended   |
| `ipvsadm`  | Optional but recommended   |


### atau bisa menjalankan dibawah ini agar lebih mempermudah saat installasinya

``` bash
sudo apt install socat conntrack ipvsadm -y
```

---

# ⌛️ Install Kubernetes Menggunakan Kubekey 

``` bash
curl -O https://raw.githubusercontent.com/config-devops/Kubesphare-v4.1.3/refs/heads/main/install-kubekey.sh

chmod +x install-kubekey.sh

./install-kubekey.sh
```

 **KubeSphere**   

 Setelah Melakukakn Installasi Kubernetes Pada Sisi Server Disini Kalian Bisa Melanjutkan 
 pada tahap installasi Kubesphere agar bisa akses menggunakan Dashboard Kubesphere

---
  Dan Berikut adalah PassWord Default Kubesphere

  - Username: admin
  - Password **P@88w0rd**
---

# ▶️ Install Kubesphare 

```bash

curl -sSL https://raw.githubusercontent.com/config-devops/Kubesphare-v4.1.3/refs/heads/main/install-kubesphere.sh | bash

```

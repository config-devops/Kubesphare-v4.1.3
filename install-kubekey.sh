#!/bin/bash
# Define color variables
set -e

BLACK=`tput setaf 0`
RED=`tput setaf 1`
GREEN=`tput setaf 2`
YELLOW=`tput setaf 3`
BLUE=`tput setaf 4`
MAGENTA=`tput setaf 5`
CYAN=`tput setaf 6`
WHITE=`tput setaf 7`

BG_BLACK=`tput setab 0`
BG_RED=`tput setab 1`
BG_GREEN=`tput setab 2`
BG_YELLOW=`tput setab 3`
BG_BLUE=`tput setab 4`
BG_MAGENTA=`tput setab 5`
BG_CYAN=`tput setab 6`
BG_WHITE=`tput setab 7`

BOLD=`tput bold`
RESET=`tput sgr0`

# Array of color codes excluding black and white
TEXT_COLORS=($RED $GREEN $YELLOW $BLUE $MAGENTA $CYAN)
BG_COLORS=($BG_RED $BG_GREEN $BG_YELLOW $BG_BLUE $BG_MAGENTA $BG_CYAN)

# Pick random colors
RANDOM_TEXT_COLOR=${TEXT_COLORS[$RANDOM % ${#TEXT_COLORS[@]}]}
RANDOM_BG_COLOR=${BG_COLORS[$RANDOM % ${#BG_COLORS[@]}]}


echo "${RANDOM_BG_COLOR}${RANDOM_TEXT_COLOR}${BOLD}Kubekey Execution${RESET}"

# 1. Download Kubekey
if [ ! -f "./kk" ]; then
  echo "${CYAN}${BOLD}📥 Downloading Kubekey...${RESET}"
  curl -sfL https://get-kk.kubesphere.io | sh -
else
  echo "${GREEN}✅ Kubekey sudah ada, skip download${RESET}"
fi

chmod +x kk

# 2. Input user
echo "${BLUE}${BOLD}⚡ Input Config Data${RESET}"
read -p "👉 ${WHITE}Masukkan versi Kubernetes (contoh: v1.26.0): ${RESET}" k8s_version
read -p "📝 ${WHITE}Masukkan nama file config (contoh: config-v1.33.1.yaml): ${RESET}" config_file
read -p "👉 ${WHITE}Berapa jumlah node? ${RESET}" node_count

common_user=""
common_pass=""
same_credential=""

if [[ "$node_count" -gt 1 ]]; then
  # Tanya user & password sama untuk banyak node
  read -p "🔑 ${WHITE}Apakah semua node menggunakan user & password yang sama? (Y/N): ${RESET}" same_credential

  if [[ "$same_credential" =~ ^[Yy]$ ]]; then
    read -p "   - User: " common_user
    read -s -p "   - Password: " common_pass
    echo ""
  fi
fi

# 4. Loop node
hosts_block=""
etcd_group=""
control_plane_group=""
worker_group=""

# 🔎 Fungsi validasi IP
validate_ip() {
  local ip=$1
  local stat=1

  if [[ $ip =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
    OIFS=$IFS
    IFS='.'
    ip_array=($ip)
    IFS=$OIFS
    [[ ${ip_array[0]} -le 255 && ${ip_array[1]} -le 255 && ${ip_array[2]} -le 255 && ${ip_array[3]} -le 255 ]]
    stat=$?
  fi
  return $stat
}

for (( i=1; i<=node_count; i++ ))
do
  echo "${RANDOM_BG_COLOR}${BOLD}⚡ Input untuk node ke-$i${RESET}"
  read -p "   - Name: " node_name

  # Validasi IP address
  while true; do
    read -p "   - Address (IP): " node_ip
    if validate_ip "$node_ip"; then
      break
    else
      echo "${RED}${BOLD}❌ IP tidak valid!${RESET} Masukkan ulang (contoh: 192.168.1.10)"
    fi
  done

  if [[ "$same_credential" =~ ^[Yy]$ ]]; then
    node_user="$common_user"
    node_pass="$common_pass"
  else
    read -p "   - User: " node_user
    read -s -p "   - Password: " node_pass
    echo ""
  fi

  hosts_block+="    - {name: $node_name, address: $node_ip, internalAddress: $node_ip, user: $node_user, password: \"$node_pass\"}\n"

  if [[ $i -eq 1 ]]; then
    etcd_group+="      - $node_name\n"
    control_plane_group+="      - $node_name\n"
    worker_group+="      - $node_name\n"
  else
    worker_group+="      - $node_name\n"
  fi
done

# 5. Generate file config
echo "${RANDOM_BG_COLOR}${BOLD}⚡ Membuat config...${RESET}"
cat > "$config_file" <<EOF
apiVersion: kubekey.kubesphere.io/v1alpha2
kind: Cluster
metadata:
  name: sample
spec:
  hosts:
$(echo -e "$hosts_block")
  roleGroups:
    etcd:
$(echo -e "$etcd_group")
    control-plane:
$(echo -e "$control_plane_group")
    worker:
$(echo -e "$worker_group")
  controlPlaneEndpoint:
    domain: lb.kubesphere.local
    address: ""
    port: 6443

  kubernetes:
    version: $k8s_version
    clusterName: cluster.local
    autoRenewCerts: true
    containerManager: containerd

  etcd:
    type: kubekey

  network:
    plugin: calico
    kubePodsCIDR: 10.233.64.0/18
    kubeServiceCIDR: 10.233.0.0/18
    multusCNI:
      enabled: false

  registry:
    privateRegistry: ""
    namespaceOverride: ""
    registryMirrors: []
    insecureRegistries: []

  addons: []
EOF

echo "${GREEN}${BOLD}✅ Config berhasil dibuat: $config_file${RESET}"
echo "${CYAN}⚡ Kubernetes version: $k8s_version${RESET}"
echo "${CYAN}⚡ Node count: $node_count${RESET}"
echo "${GREEN}${BOLD}🎉 Selesai! File config ada di $config_file${RESET}"

echo "${YELLOW}⚡ Tunggu sebentar sebelum menjalankan cluster...${RESET}"
for i in {10..1}; do
    echo -ne "${CYAN}⏳ Mulai dalam $i detik...\r${RESET}"
    sleep 1
done

echo "${RANDOM_BG_COLOR}⚡ Menjalankan Script $config_file${RESET}"

./kk create cluster -f $config_file



function random_congrats() {
    MESSAGES=(
        "${GREEN}🎉 Selamat! Kamu berhasil menyelesaikan lab ini dengan baik!${RESET}"
        "${CYAN}💪 Mantap! Usaha kerasmu akhirnya terbayar tuntas!${RESET}"
        "${YELLOW}🔥 Keren banget! Kamu sukses menaklukkan tantangan ini!${RESET}"
        "${BLUE}🚀 Hebat! Dedikasimu bikin hasilnya luar biasa!${RESET}"
        "${MAGENTA}👏 Selamat! Satu langkah lagi menuju level berikutnya!${RESET}"
        "${RED}⚡ Fantastis! Kamu sudah menuntaskan lab ini dengan sukses!${RESET}"
        "${CYAN}🙌 Luar biasa! Ketekunanmu membawa hasil yang gemilang!${RESET}"
        "${GREEN}🌟 Bagus banget! Semangatmu patut diacungi jempol!${RESET}"
        "${YELLOW}✅ Selamat! Kamu sudah menyelesaikan misi ini dengan sukses!${RESET}"
        "${BLUE}🏆 Mantap sekali! Terus pertahankan performa hebatmu!${RESET}"
        "${MAGENTA}🔥 Keren! Keuletanmu bikin hasilnya memuaskan banget!${RESET}"
        "${RED}🎯 Sempurna! Kerja kerasmu membuahkan hasil terbaik!${RESET}"
        "${CYAN}💡 Brilliant! Kamu benar-benar menguasai langkah ini!${RESET}"
        "${GREEN}🌈 Good job! Progresmu makin terlihat jelas sekarang!${RESET}"
        "${YELLOW}🥳 Selamat! Kamu berhasil melewati semua tantangan!${RESET}"
        "${BLUE}💥 Dahsyat! Kamu sudah menaklukkan lab ini dengan lancar!${RESET}"
        "${MAGENTA}🚀 Awesome! Terus konsisten, sukses besar menunggumu!${RESET}"
        "${RED}🏅 Luar biasa! Prestasimu hari ini patut dirayakan!${RESET}"
    )

    RANDOM_INDEX=$((RANDOM % ${#MESSAGES[@]}))
    echo -e "${BOLD}${MESSAGES[$RANDOM_INDEX]}"
}

# Display a random congratulatory message
random_congrats

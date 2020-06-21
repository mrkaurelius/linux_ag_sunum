# Linux Ağ Yönetimi Final Projesi 
# Abdulhamit Kumru 170202020 

\pagebreak

## Makinelerin Klonlanması

!!! makinelerin klonlanmasini ekle
!!! programlar hakkında metadata ekle

## Senaryo 1

### NAT ile Host-Guest Ubuntu PC Bağlantısı 

Başlangıc olarak guest makinenin Network Adapterini NAT olarak seçiyoruz

![NAT adapter ayarı](./s1/upc1natconfig.png){ height=200px }

##### SSH 

host makineye NAT bağlantı ile erişebilmek için öncelikle gerekli gerekli portu yönlendiriyoruz
daha sonra gueste ssh ile bağlanabilmek için open-ssh serveri apt ile yüklüyoruz.

![Port forwarding](./s1/natportfrw.png){ height=200px }

```bash
$ apt install opessh-server
```

ssh server servisinin ayarlarını  dosyasından 22 numaralı portu ve parolayı kabul edicek
şekilde yapıyoruz.

```bash
$ echo "Port 22" >> /etc/ssh/sshd_config
$ echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config
```

Ayarların aktif olmasi için ssh servisimizi yeniden başlatıyoruz.

```bash
$ sudo service ssh restart
```

Forward ettiğimiz port üzerinden guest'e bağlabiliriz.

```bash
$ ssh kumru@192.168.1.100 -p 22222 # hostun ip adresi
```

![Gueste ssh ile baglanma](./s1/natsshscsh.png){ height=180px }

#### Ping

Eğer ICMP port ile çalışsaydı aynı şekilde onunda portunu yönlendirip gueste ping atabilirdik fakat ICMP
TCP/UDP portları üzerinden çalışmıyor.

![Gueste ping gönderilemiyor](./s1/cantping.png){ height=180px }

#### Misafir Eklentileri 

Misafir eklentilerini guest makinye sanal disk takarak yükleyebiliyoruz bu sayade hosttan gueste veya guestten
hosta kopyala yapıştır ve dosya sürekle bırak yapabiliyoruz. Eklentiyi yüklelemek zor değil sanal makine
penceresinden `Devices > Insert Guest Additions CD...` seçeneğini seçince bize autorun.sh'ı çalıştırayım mı
diye soruyor evet diyip parolamızı girince eklentiler yükleniyor

![autorun.sh çıktısı](./s1/misafireklentisiyukleme.png){ height=180px }

Sanal makinenin penceresinden  `Devices > Drag and Drop`, `Devices > Shared Clipboard` seçeneklerinden detaylı
ayar yapılabilir.

![Gueste eklentileri ile sürükle bırak](./s1/dragdrop.png){ height=180px }

### Network Bridge ile Host, TinyCore Guest Bağlantısı

Guestin network adapter ayarını Bridge Adapter olarak seçiyoruz

![Network Bridge Ayarı](./s1/tcnetconf.png){ height=180px }

TinyCoreda IP'mizi ifconfig komutu ile kontol edebiliyoruz.

![ifconfig çıktısı](./s1/tcip.png){ height=180px }

Network Bridge ile Guest LANdaki makine gibi kullanılabilir.

#### SSH

tce-load programı ile TinyCoreda program yükleyebiliyoruz.

```bash
# openssh client/server paketini yukleme
tce-load -w -i openssh.tcz
# ssh/sshd ayarlari
cp /usr/local/etc/ssh/ssh_config.orig /usr/local/etc/ssh/ssh_config
cp /usr/local/etc/ssh/sshd_config.orig /usr/local/etc/ssh/sshd_config
echo "Port 22" >> /usr/local/etc/ssh/sshd_config
echo "PasswordAuthentication yes" >> /usr/local/etc/ssh/sshd_config
# servisi calistirma
/usr/local/etc/init.d/openssh start
```

![Gueste ssh bağlantısı](./s1/tcssh.png){ height=180px }

#### Ping

![Gueste ping gönderebiliyoruz](./s1/tcping.png){ height=180px }

### Host only Adapter ile Host, Ubuntu Server Guest Bağlantısı

Host only Adapter kullanabilmek için öncelikle Host Network oluşturmak gerekli. Ana Menüden 
`File > Host Network Manager...`i seçip create tıklıyoruz ve Network Oluşuyor.

![Host Network](./s1/hostnetworkmanager.png){ height=180px }

Guestimizin Network adapterini Host only Adapter seçip alt seçenekten oluşturduğumuz Host Network'ü seçiyoruz.

![Host Only Adapter Ayarı](./s1/hostonlyuserver1advanced.png){ height=180px }

yaml fromatındaki `/etc/netplan/50-cloud-init.yaml` dosyasını Network Interfacemizi DHCP ile yönetilmesi için
ayarlıyoruz

```yaml
# /etc/netplan/50-cloud-init.yaml
network:
  version: 2
  renderer: networkd
  ethernets:
    enp0s9:
      dhcp4: yes
```

Yeni ayarların kullanması için netplan komutunu çalıştırıyoruz.

```bash
$ sudo netplan --debug apply
```

![Host-only Adapterin Host Networkten aldığı IP.](./s1/hostonlyuserverip.png){ height=180px }

#### SSH

NAT ile Host, Guest Ubuntu PC Bağlantısı bölümünde yaptığımız komutları burada tekrar ediyoruz.

```bash
$ apt install opessh-server
$ echo "Port 22" >> /etc/ssh/sshd_config
$ echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config
$ sudo service ssh restart
```

userver1'e SSH ile bağlanıyoruz.

```bash
$ ssh kumru@192.168.56.101
```

![Gueste ssh ile bağlanma](./s1/hostonlysshuserver.png){ height=180px }

\pagebreak

#### Ping

![Gueste Ping gönderme](./s1/hostonlypinguserver.png){ height=180px }

\pagebreak

## Senaryo 2

#### Internal Network ile Host-Guest, Guest-Guest Bağlatısı

#### Internal Network Ayarı

Senaryo geregi ip Ubuntu Serverlarin ipleri 

`host: 192.168.0.1
userver1: 192.168.0.2
userver2: 192.168.0.3
userver3: 192.168.0.4`

Internal network için Network Adapterin modunu seçmek yeterli.

![Internal Network Ayarları](./s2/userverinternalconf.png){ height=180px }

#### Netplan Ayarları

netplan ayarlarını Senaryo 1 de yaptığımız gibi yapıyoruz. Farklı olarak dhcp olmadan statik bir şekilde IP 
alıyoruz

```yaml
# /etc/netplan/50-cloud-init.yaml
# S:0 R:2
network:
  version: 2
  renderer: networkd
  ethernets:
    enp0s8:
      dhcp4: no
      addresses:
        - 192.168.0.2/24 # userver1 için
      gateway4: 192.168.0.1
      nameservers:
          # aslinda nameserver ayarlamanın anlamı yok ama adet yerini bulsun
          addresses: [8.8.8.8, 1.1.1.1]
```

#### SSH

SSH server yüklediğimiz için ve diğer makineler klon olduğu için bir daha SSH yükleme ve ayarlamaya gerek yok.
Guestler arasında SSH bağlantısı yapılabiliyor.

![Guestler Arasında SSH](./s2/userverguestssh.png){ height=180px }

![Guestler Arasında SSH](./s2/userverguestssh2.png){ height=180px }

Internal Networkte hostdan guestlere ulaşmak mümkün değil.

![Hosttan Gueste SSH denemesi](./s2/userverhostssh.png){ height=180px }

#### Ping

Guestler birbirlerine ulaşabildiği için birbirlerine ping göndermeleri mümkün.

![Guestler Arası Ping](./s2/userverguestping.png){ height=180px }

#### SCP

Gerek olmasada boş dosya göndermek yerine sıfır yazılmış 100M büyüklüğünde dosyalar gönderelim.

```bash
# dosyalari hazirlama
$ dd if=/dev/zero of=abdulhamit.txt count=100 bs=1M
$ cat abdulhamit.txt > kumru.txt > 170202020.txt
# scp komutu
$ scp *.txt 192.168.0.3:/home/kumru/
```

![scp Komutu Çıktısı](./s2/userverscp.png){ height=180px }

## Senaryo 3
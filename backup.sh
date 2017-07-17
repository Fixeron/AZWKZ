#!/bin/sh

# @version $Id: backup.sh 12 2017-07-17 01:30:14Z Fixer $
# @date $Date: 2017-07-17 11:30:14 +1000 (Pn, 17 lip 2017) $
# @revision $Revision: 12 $
# @author $Author: Fixer $
# @headurl $HeadURL: svn://fixer.synology.me/repo_backup/backup.sh $

#  BBBBBBBBBBBBBBBBB               AAA                  CCCCCCCCCCCCCKKKKKKKKK    KKKKKKKUUUUUUUU     UUUUUUUUPPPPPPPPPPPPPPPPP   
#  B::::::::::::::::B             A:::A              CCC::::::::::::CK:::::::K    K:::::KU::::::U     U::::::UP::::::::::::::::P  
#  B::::::BBBBBB:::::B           A:::::A           CC:::::::::::::::CK:::::::K    K:::::KU::::::U     U::::::UP::::::PPPPPP:::::P 
#  BB:::::B     B:::::B         A:::::::A         C:::::CCCCCCCC::::CK:::::::K   K::::::KUU:::::U     U:::::UUPP:::::P     P:::::P
#    B::::B     B:::::B        A:::::::::A       C:::::C       CCCCCCKK::::::K  K:::::KKK U:::::U     U:::::U   P::::P     P:::::P
#    B::::B     B:::::B       A:::::A:::::A     C:::::C                K:::::K K:::::K    U:::::D     D:::::U   P::::P     P:::::P
#    B::::BBBBBB:::::B       A:::::A A:::::A    C:::::C                K::::::K:::::K     U:::::D     D:::::U   P::::PPPPPP:::::P 
#    B:::::::::::::BB       A:::::A   A:::::A   C:::::C                K:::::::::::K      U:::::D     D:::::U   P:::::::::::::PP  
#    B::::BBBBBB:::::B     A:::::A     A:::::A  C:::::C                K:::::::::::K      U:::::D     D:::::U   P::::PPPPPPPPP    
#    B::::B     B:::::B   A:::::AAAAAAAAA:::::A C:::::C                K::::::K:::::K     U:::::D     D:::::U   P::::P            
#    B::::B     B:::::B  A:::::::::::::::::::::AC:::::C                K:::::K K:::::K    U:::::D     D:::::U   P::::P            
#    B::::B     B:::::B A:::::AAAAAAAAAAAAA:::::AC:::::C       CCCCCCKK::::::K  K:::::KKK U::::::U   U::::::U   P::::P            
#  BB:::::BBBBBB::::::BA:::::A             A:::::AC:::::CCCCCCCC::::CK:::::::K   K::::::K U:::::::UUU:::::::U PP::::::PP          
#  B:::::::::::::::::BA:::::A               A:::::ACC:::::::::::::::CK:::::::K    K:::::K  UU:::::::::::::UU  P::::::::P          
#  B::::::::::::::::BA:::::A                 A:::::A CCC::::::::::::CK:::::::K    K:::::K    UU:::::::::UU    P::::::::P          
#  BBBBBBBBBBBBBBBBBAAAAAAA                   AAAAAAA   CCCCCCCCCCCCCKKKKKKKKK    KKKKKKK      UUUUUUUUU      PPPPPPPPPP 

# SKRYPT  "AZWKZ"
#    Automatyzacja Zadań Wykonywania Kopii Zapasowych (ustawień DSM, baza mariaDB, web, fotki, svn) na serwerze Synology 
#    z możliwością wysłania takiej kopii na dodatkowy zewnętrzny serwer FTP.
#    also know as: Automated, Bulletproof File Backup Solution

# INFO:
#            version: 2.8 / 17 JULY 2017 r.
#             author: fixer
#            license: BeerWare - buy the author a beer "in return"
# compatibility with: Synology DS1515+ / DSM 5.2.x / Intel Atom C2538 (64-bit) / i686-pc-linux-gnu version 3.10.35 / 2GB RAM

# REQUIREMENTS:
#    - ncftp 3.2.6 (do pobrania z: http://www.ncftp.com/download/) => binarki skopiuj do: (/usr/bin/ncftp) 
#      następnie nadaj uprawnienia do wykonywania: find "/usr/bin/ncftp/" -exec chmod 755 {} \;
#    
#    - p7zip 16.02 (do pobrania z: https://sourceforge.net/projects/p7zip/files/p7zip/16.02/) => binarki skopiuj do: 
#      (/usr/bin/p7zip) następnie nadaj uprawnienia do wykonywania: find "/usr/bin/p7zip/" -exec chmod 755 {} \;
#    
#    - 7zip 9.20 (jest w synology)
#    - tar 1.26 (jest w synology)
#    - curl 7.36.0 (jest w synology)
#    - the following commands: find/chmod/cksum/grep/date (jest w synology)
#    - mysql-MariaDB 5.5.47 (jest w synology)
#    - mysqldump 10.14 (jest w synology)
#    - postgreSQL 9.3.6
#    
#    - php (jest w synology)
#    - Nadać temu skryptowi prawa do wykonywania -> chmod 755 /volume1/backup/backup.sh
#    - chown root:root backup.sh
#    - Pamięć: min 100MB wolnej pamięci RAM

# DODATKOWO:
#    openssl
#    serwer pocztowy z obsługą funkcji mail()
#    rar 5.40 do pobrania: http://www.rarlab.com/download.htm (klucz licencyjny rarreg.key należy skopiować do /etc/)

# ZNANE PROBLEMY:
#   - przed każdym włączeniem skryptu zalecam restart NAS'a (na czystym starcie ma wiecej pamięci, unikamy zakleszczeń i generalnie lepiej chodzi)
#   - sprawdź czy zostały spakowane pliki, które w nazwie zawierają spację lub znaki diakrytyczne 
#     szukaj w logach "Cannot find ..." albo "WARNINGS for files"
#   - dolary ($) w hasłach psują archiwum 7z oraz nie pozwalają się poprawie połączyć z serwerem FTP
#   - mysqldump nie exportuje (Views/Procedures/Fuctions (--routines=true)/Triggers(--triggers)/Events)
#   - *.tar nie potrafi zabezpieczyć archiwum hasłem
#   - 7-zip in Linux/Unix does not store the owner/group of the file (dlatego volume1/web/ pierw pakujemy tar'em)
#   - 7zip (w wersji dosowej 9.20) nie obsługuje przełącznika -sdel (usuwamy źródło po spakowaniu)
#   - hasła wysyłane przy połączeniu do ściągania z serwera FTP są wysyłane czystym tekstem 
#     użyć SFTP albo pakować bezpośrednio na serwerze i ściągać spakowany i zaszyfrowany plik *.7z
#   - 7zip nie zapisuje pełnych ścieżek do wskazanego folderu, który jest gdzieś w środku ścieżki (dlatego używamy do tego lepszego p7zip'a)
#   - 7zip nie wspiera kopii przyrostowych gdzie pełna kopia jest podzielona na volumen'y :(

# FUNKCJE:
#   1) automatycznie usuwa wszystkie stare backup'y ze wskazanej ścieżki lokalnej (NAS) i zdalnej (FTP)
#   
#   2) automatyczny backup wszystkich baz danych (z możliwością wykluczenia wybranych baz) 
#      z lokalnego lub zdalnego serwera mysql/mariadb do tymczasowych osobnych plików *.sql a następnie 
#      spakowanie (każdego z osobna) do wynikowego pliku *.7z (+silna kompresja + szyfrowanie + hasło)
#   
#   3) automatyczny backup wskazanego folderu na nasie (wraz z jego zawartością) 
#      z możliwością wykluczenia wybranych w nim pod-folderów i/lub typów plików
#   
#   4) generowane archiwa z silną kompresją + zabezpieczenie hasłem + szyfrowanie 256 bit + dzielenie na volumen'y
#   
#   5) kopia na dysk synology + lustrzana kopia wysyłana na zdalny serwer FTP (np. do chmury)
#      (wysyłamy tylko pliki z nazwą "backup_.*" czyli bez archiwów typu "photo_.*"")
#   
#   6) zapisuje logi (uproszczone i listing) do pliku *.log (tam gdzie ustawiono robienie backup'u) - ich 
#      skompresowana i zabezpieczona wersja jest wysyłana na serwer ftp
#   
#   7) wysyła powyższe logu na maila (w oparciu o wpisany SMTP na synku)
#   
#   8) kopia zawartości folderu (/volume1/photo/) archiwa są zapisywane na NAS'ie bez kompresji z podziałem na płyty DVD i bez wysyłania 
#      na zewnętrzny serwer FTP (z racji dużej wielkości).
#   
#   9) zapisywanie do logów wielkości plików wynikowych + suma kontrolna crc32 dla plików wysyłanych na serwer FTP
#   
#   10) możliwość wysyłania plików przez protokół FTP za pomocą wbudowanego w synology klienta "curl 7.36.0" lub 
#       przez darmowego "ncftp 3.2.6" (do pobrania z: http://www.ncftp.com/download/)
#   
#   11) wykonuje kopię zapasową lokalnych zasobów repozytoriów SVN (fizyczne pliki bazy i/lub *.dump) + pakuje i szyfruje
#   
#   12) ściąganie plików z zewnętrznego serwera ftp (za pomocą curl i ncftp) na NAS'a z bazami danych mysql/mariadb włącznie
#   
#   13) robienie kopii ustawień DSM do pliku *.dss
#       Z poziomu DSM: Control Panel > Update & Restore > Configuration Backup > "Back up configuration"
#       The following system configurations will be backed up: User, Group, Shared Folder, Workgroup, Domain, and LDAP, 
#       Windows File Service, Mac File Service, NFS, FTP, Network Backup, WebDAV, Web Services, SNMP, User Home, 
#       Password Settings, Task Scheduler, Disk Usage Report Settings
#   
#   14) robienie kopii wybranych plików i/lub folderów zawierające ustawienia w synology
#   
#   15) sprawdzenie archiwum pod kątem poprawności spakowania (znacząco wydłuża backup ale też zwiększa bezpieczeństwo)
#   
#   16) pobiera i zapisuje wiele informacji o sprzęcie, dyskach, partycjach, ustawieniach raid'ach i status S.M.A.R.T.
#   
#   17) możliwość szyfrowania i pakowania bez kompresji do 7z każdego pliku z osobna i wysłanie na serwer FTP z zachowaniem układu folderów
#       rozwiązanie dedykowane dla filmów i zdjeć
#   
#   18) /volume1/web/ jest teraz pierw pakowany do tar'a a następnie do 7z'pa - dzięki temu zachowujemy uprawnienia nadane plikom 
#       ponieważ 7zip tego niestety nie potrafi
#
#   19) zrzut bazy PostgreSQL

# TODO:
#    1)  przetłumaczenie w całości na EN
#    2)  restore postgresql: /usr/syno/pgsql/bin/psql photo  </volume2/dane/photo.sql
#    3)  wygenerowanie debug.dat z synology
#    4)  potrzebna rotacja plikami kopii zapasowych
#    5)  opcja poprawnego przywracania plików z *.7z i bazy danych z *.7z
#    6)  https://github.com/CutePoisonX/Bash
#    7)  ściąganie curlem plików z zew ftp
#    8)  backup dyferencyjny
#    9)  rsync
#    10) wybór pomiędzy rar a p7zip'em
#        7zip - lepsze upakowanie danych ale dłużej pakuje
#        rar - szybko pakuje ale słabiej kompresuje dane
#    11) pomijanie silnej kompresji przy tych typach danych: 
#    zip, rar, mp3, mp4, avi, 7z, gif, png, jpeg, jpg, mpg, mpeg, gz, gzip, mov, swf mkv, vob, wmv, flv, mts
#    .3fr,.3gp,.7z,.aac,.ai,.ape,.arj,.arw,.asd,.asf,.avi,.bay,.bin,.bz2,.cab,.cap,.cr2,.crw,.dat,.dcr,.dcs,
#    .djvu,.dll,.dmg,.dng,.drf,.eip,.erf,.exe,.fff,.flac,.flv,.gif,.gzip,.iiq,.iso,.k25,.kdc,.m4a,.mef,.mkv,
#    .mos,.mov,.mp4,.mp4v,.mpc,.mrw,.msi,.nef,.nrg,.nrw,.ogg,.orf,.pdf,.pef,.psd,.ptx,.pxn,.R3D,.raf,.raw,
#    .rmbv,.rw2,.rwl,.rwz,.sr2,.srf,.sqx,.tar.bz2,.tar.gz,.tif,.tiff,.vdi,.vmdk,.vob,.wav,.webm,.wma,.wmv,
#    .x3f,.r01,.r02,.r03,.r04,.r05,.r06,.r07,.r08,.r09,.r10,.r11,.r12,.r13,.r14,.r15,.r16,.r17,.r18,.r19,.r20,
#    .r21,.r22,.r23,.r24,.r25,.r26,.r27,.r28,.r29,.r30,.r31,.r32,.r33,.r34,.r35,.r36,.r37,.r38,.r39,.r40,.r41,
#    .r42,.r43,.r44,.r45,.r46,.r47,.r48,.r49,.r50,.zip,.001,.002,.003,.004,.005,.006,.007,.008,.009,.010,.011,
#    .012,.013,.014,.015,.016,.017,.018,.019,.020,.021,.022,.023,.024,.025,.026,.027,.028,.029,.030,.031,.032,
#    .033,.034,.035,.036,.037,.038,.039,.040,.041,.042,.043,.044,.045,.046,.047,.048,.049,.050,.mpeg,.jpg,.jpeg,
#    .mp3,.nrg"                           


# tu znajdziesz konfigurację i ustawienia dla tego skryptu
source "backup_config.sh"


# zbieramy przydatne informacje o NAS'ie
source "backup_info.sh"


# TODO: działa ale wymaga jeszcze poprawienia
# UWAGA: USUWA BEZ POTWIERDZENIA PLIKI (zaczynające się na "backup_" oraz "photo_") ZE WSKAZANEGO FOLDERU i podfolderów na NAS'ie!!!
source "backup_remove_local.sh"


# UWAGA: USUWA BEZ POTWIERDZENIA WSZYSTKIE PLIKI ZACZYNAJĄCE SIĘ NA "backup_" ZE WSKAZANEGO FOLDERU NA SERWERZE FTP!!!
source "backup_remove_remote.sh"


# wykonujemy kopię konfiguracji DSM do *.dss a potem pakujemy do *.7z
source "backup_dss.sh"


# sprawdzamy ile jest wolnej pamięci, jeśli jest mniej jak 100mb to zatrzymujemy skrypt
#source "backup_memory.sh"


# wykonujemy kopię bazy danych mariaDB na nas'ie
source "backup_mariadb.sh"


# wykonujemy kopię bazy danych postgreSQL na nas'ie
# TODO: pg_ctl -D /volume1/@database/pgsql reload
# synoservicecfg --restart pgsql
# pg_ctl -m fast restart
source "backup_postgresql.sh"


# wykonujemy kopię folderu /volume1/web na nas'ie
source "backup_web.sh"


# wykonujemy kopię folderu: /volume1/svn
#source "backup_svn.sh"


# zamiast kopiować żywcem foldery (jak wyżej) lepiej zrobić zrzut z bazy Subversion do pliku *.dump
source "backup_svn_dumps.sh"


# kopiujemy folder /volume1/photo
source "backup_photo.sh"


# pobieramy pliki z zewnętrznego serwera FTP na NAS'a
source "backup_download_ftp_1.sh"
source "backup_download_ftp_2.sh"


# wysyłamy curl'em lub przez NCFTP wszystkie pliki (zaczynające się na "backup_" i będące w głównym katalogu) na zdalną 
# chmurę przez FTP. CURL wspiera następujące protokoły: DICT, FILE, FTP, FTPS, Gopher, HTTP, HTTPS, IMAP, IMAPS, LDAP, 
# LDAPS, POP3, POP3S, RTMP, RTSP, SCP, SFTP, SMTP, SMTPS, Telnet i TFTP
source "backup_upload_ftp.sh"

# tu możemy zdefiniować kolejny serwer FTP jako mirror kopii zapasowej


# tu pakujemy pliki odpowiedzialne za ustawienia naszego nasa (można też indywidualnie dodać inne ścieżki...)
source "backup_nas_configfiles.sh"


# Funkcja w fazie testów (pakowanie i szyfrowanie każdego pliku z osobna bez kompresji do 7zip'a i wysyłanie na serwer FTP z zachowaniem układu oryginalnych ścieżek)
# metoda znajduje zastosowanie w przypadku dużych plików multimedialnych np. video (mpg/mp4/mov/avi/wmv)
# TODO:
#source "backup_1by1.sh"


echo "The total amount of data: `du -sh "$BACKUP_DIR" | awk '{print $1}'`" >> "$LOG_FILE"
echo "=====================================" >> "$LOG_FILE"
echo "[$(date +'%d-%m-%Y %H:%M:%S')] JOB DONE!" >> "$LOG_FILE"


# na koniec wysyłamy pełne logi na FTP
source "backup_upload_logs.sh"


# wysyłamy maila z logami
source "backup_mail.sh"

exit 0

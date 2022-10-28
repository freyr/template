# Brakujące tematy

## .dockerignore
Aby polecenie COPY . . nie kopiowało niepotrzebnych plików z repozytorium należy nalogicznie jak dla .gitignore dodać maski (glob) które odfiltrują niepotrzebne pliki/katalogi
W wypadku .dockerignore zaleca się aby używać filtrów "pozytywnych" czyli najpierw odfiltrowujemy 
wszystko a dopiero potem dodajemy "wyjątki" na poszczególne katalogi. 
W ten sposób unikamy sytuacji w której do kontekstu build'a trafiają pliki przez przypadek.

## Makefile
Na potrzeby uproszczenia procesu konfiguracji w repo znajduje 
się plik Makefile (MacOS i Linux mają to narzędzie wbudowane). 
Makefile pozwala na definiowanie atomowych polecen i grupowania 
ich w sekwencje. 
Pozwala to drastycznie uprościć proces konfigurowania środowiska dla aplikacji

Help dla poleceń w Makefile można uzyskać wykonując make bez parametrów

## konfiguracja phpstorm
W PHPstorm znajduje się zestaw konfiguracji uruchomieniowych do sterowania środowiskiem i testami jednostkowymi
Całość opiera się w dużej częsci na Makefile

## konfiguracja php-fpm
W katalogi .image znajduje się bardziej rozbudowana struktura plików konfiguracyjnych na nginx/php/fpm tak aby rozdzielić części wspólne od
konfiguracji typowo "developerskich" czy "produkcyjnych". Ciekawąstką jest to że konfiguracja dla php.ini jest "składana" z wielu niezależnych plików *.ini, 
można więc izolować konfiguracje poszczególnych obszarów php (tak jak jest dla np. xdebug czy error-reporting.ini)
Wszystkie pliki php/*.ini są kopiowane do obrazu i ładowane przez php

# Uruchomienie
Zakładając że środowisko "traefik" jest zbudowane i skonfigurowane poprawnie
wystarczy wykonać polecenie `make create` lub odpalić stosowną akcję w phpstorm aby środowisko zostało zbudowane i uruchomione
aplikacja startuje pod adresem `https://template.phpcon-dev.pl`

Można też uruchomić testy jednostkowe z poziomu PHPStorm lub makefile (`make test`)

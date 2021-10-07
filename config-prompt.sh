#!/usr/bin/env bash
# <https://github.com/Matiusco/ps1-bash/>
# coding	: utf-8
# 
# support	: 
# LICENSE	: GNU General Public License v3.0
# VERSION	: '1.98-alfa' 
#-----------------------------------------------------------------------
# This script is inspired by the beautiful work done 
# by Paulo Kretcheu <https://github.com/kretcheu/devel/>
#-----------------------------------------------------------------------
# Many code examples were adapted from Teacher BlauAraujo's bash course
# <https://debxp.org/cbpb//>
#-----------------------------------------------------------------------
# You are encouraged to collaborate in translate into English 
# or other languages. Contact-me here in github.
# New prompt color suggestions can be sent in issue.
#-----------------------------------------------------------------------

#-----------------------------------------------------------------------
# Global Vars
#-----------------------------------------------------------------------

lista=$1 # Parâmetro de entrada durante a configuração. 
MY_SCRIPT=config-prompt.sh
CONFIG_FILE=.bashrc
UPDATE_PS1_SELECTED=FALSE # FALSE or true 
NUMERO_CONFIG="" # Escolhido durante a configuração.
INSTALL_serial_number="0" # Gera somente uma vez, ou até apagar arquivo.

# Endereco do meu .bashrc
MY_BASH_RC=$HOME/$CONFIG_FILE

# vars instalacoes. 
DIR_PROMPT_INSTALL=$HOME/.prompt/ps1-bash
[ -d "$DIR_PROMPT_INSTALL" ] || mkdir -p "$DIR_PROMPT_INSTALL"

# file installed
FILE_INSTALLED="${DIR_PROMPT_INSTALL}/${MY_SCRIPT}"
if [ ! -f "$FILE_INSTALLED" ]; then
	cp "${MY_SCRIPT}" "${FILE_INSTALLED}"
fi

# Permite chamar pelo apelido. 
if ! command -v ps1-bash &> /dev/null ; then
	alias ps1-bash="${FILE_INSTALLED}"
fi

# Diretório de backups sobre alterações. Histórico.
DIR_PROMPT_BKP=$HOME/.prompt/BKP
[ -d "$DIR_PROMPT_BKP" ] || mkdir -p "$DIR_PROMPT_BKP"

# diretorios de ps1 anterior e atual. 
DIR_PROMPT_PS1=$HOME/.prompt/PS1
[ -d "$DIR_PROMPT_PS1" ] || mkdir -p "$DIR_PROMPT_PS1"

# Cores

COR[0]="\[\e[0m\]" 		# Normal
COR[1]="\[\e[1;31m\]" 	# Vermelho
COR[2]="\[\e[1;32m\]" 	# Verde
COR[3]="\[\e[1;33m\]" 	# Amarelo
COR[4]="\[\e[1;34m\]" 	# Azul
COR[5]="\[\e[1;35m\]" 	# Roxo
COR[6]="\[\e[1;36m\]" 	# Cian
COR[7]="\[\e[1;37m\]" 	# Branco
COR[8]="\[\e[1;96m\]" 	# Azul Claro

DES[0]="\342\224\214\342\224\200" # Linha de canto
DES[1]="\342\224\224\342\224\200\342\224\200\342\225\274" # Linha e ponto
DES[2]="\342\234\227" # Sinal de erro
DES[3]="\342\224\200" # Linha horizontal

#orientacao="Usage: ./prompt [themeNumber]"

#-----------------------------------------------------------------------
# End Global vars
#-----------------------------------------------------------------------

#-----------------------------------------------------------------------
# Start functions
#-----------------------------------------------------------------------

# thanks fff.sh script.
__setup_terminal() {
    # Setup the terminal for the TUI.
    # '\e[?1049h': Use alternative screen buffer.
    # '\e[?7l':    Disable line wrapping.
    # '\e[?25l':   Hide the cursor.
    # '\e[2J':     Clear the screen.
    # '\e[1;Nr':   Limit scrolling to scrolling area.
    #              Also sets cursor to (0,0).
    printf '\e[?1049h\e[?7l\e[?25l\e[2J\e[1;%sr' "$max_items"

    # Hide echoing of user input
    stty -echo
}

#-----------------------------------------------------------------------
# thanks fff.sh script.
#-----------------------------------------------------------------------
__reset_terminal() {
    # '\e[?7h':   Re-enable line wrapping.
    # '\e[?25h':  Unhide the cursor.
    printf '\e[?7h\e[?25h'

    # Show user input.
    stty echo
}

#-----------------------------------------------------------------------
# :TODO: Needed translate to English by default.  Pendency
#-----------------------------------------------------------------------
__info_prompt() {

	local info_uso=$(cat <<EOF
#------------------------------------------#
 Testado em versões Buster e Sid do Debian. 
 Serão duas formas diferentes de usar, você
 irá escolher qual será melhor no seu caso.

 Gravará a PS1 comentada, #PS1 
 Vai estar no final de seu ~/.bashrc 
 Pode descomentar para usar. 
   
 Faz source/include no fim do seu ~/.bashrc 
 Esta será a opção padrão de uso. 
 Sempre faz backup de seu ~/.bashrc original.
#------------------------------------------#

EOF
)
	printf "${info_uso}\n"
}


__help() { 
	local help_uso local_install
	local_install="$1"
	help_uso=$(cat <<EOF
#------------------------------------------#
 Para ver os prompts, apenas digite:
 
 ps1-bash 

 Para escolher, veja qual o número dele e:
 
 ps1-bash NumeroEscolhido 
 
 Caso queira outras opções sem bateria, 
 com ou sem uso da memória, por enquanto 
 vai precisar alterar dentro do arquivo 	
 config-prompt.sh 
 
 Você sabe onde ele está instalado quando
 configura uma nova cor de prompt. 
 Localize o script e abra em seu editor.

 Gostou ? Dê novas sugestoes no grupo debxp.
#------------------------------------------#
EOF
)
	printf "${help_uso}\n"
	printf "Instalado em: ${local_install}\n"	
	__reset_terminal
	exit 0

}	
#-----------------------------------------------------------------------
# Iniciando a instalação de um novo prompt.
# Se você desejar. 
#-----------------------------------------------------------------------
__instalar_prompt() {
	local CONFIRMANDO escolha ps1_escolhida 
	stty echo
	ps1_escolhida="$1"
	__reset_terminal
	read -t 10 -p " Escreva (sim) para gravar o PS1: " escolha
	#printf "\n"

	escolha=${escolha:-nao}
	if [ $escolha == "sim" ]; then

		# Global var.
		UPDATE_PS1_SELECTED=TRUE

		read -t 10 -e -p  " Voce tem certeza [S/N]?: " CONFIRMANDO

		if [[ $CONFIRMANDO == "S" || $CONFIRMANDO == "s" ]]; then 
			CONFIRMANDO=Yes

			# Backup unico do original. 
			__save_bkp_inicial

			# Mudando status 
			UPDATE_PS1_SELECTED=FALSE

			# Confere qual ps1 escolheu e qual tinha.
			__chk_last_ps1 "$ps1_escolhida" 

			if [[ "$UPDATE_PS1_SELECTED" == "TRUE" ]]; then
				# Continuando o update do PS1. 
				# Ja sabemos q as versoes sao diferentes.
				# Gravar o atual como old.
				__save_positions "$ps1_escolhida"
				__altera_bashrc "$ps1_escolhida" "$INSTALL_serial_number" 
				printf " <<<Alterou o seu bashrc >>> ...\n" 
				read -t 3
				printf " Quer atualizar o prompt agora ? >>> \n" 
				printf " reload-prompt \n" 
				printf " Quer configurar novamente ? >>> \n" 
				printf " ps1-bash  \n" 
				read -t 2
			else
				printf " $LINENO : Atualização abortada.... "
				read -t 5
				clear 
			fi
		else
			#CONFIRMANDO=No
			printf " Não confirmou, saindo.... "
			read -t 5
			clear 
			return 1
		fi
	else
		printf " Abortou a missão, nao vai atualizar "
		read -t 5
		clear
		return 1 
	fi

}

#-----------------------------------------------------------------------
# Save positions 
#-----------------------------------------------------------------------
__save_positions() {  
	ps1_escolhida="$1"
	# Save positions ans locals if necessary.
	__save_ps1_old # move o last para old.
	__save_ps1_atual "$ps1_escolhida" # salva somente o last q eh a PS1 escolhida. 
	__save_bkp_log # Antes de gerar alteracoes no .bashrc
	__save_local_install # Salva script para dir install
	__pega_serial # Pegando o serial.
} 

#-----------------------------------------------------------------------
# Save backup of default .bashrc file
#-----------------------------------------------------------------------
__save_bkp_inicial() {
	# precisa achar solucao para isso. 
	# Tá esquisito ainda...
	BACKUP_FILE=$CONFIG_FILE.bak.prompt
	bkp_inicial="${DIR_PROMPT_BKP}/${BACKUP_FILE}"
	if [ ! -f "$bkp_inicial" ]; then
		cp "${MY_BASH_RC}" "${bkp_inicial}" 

		echo " Salvando arquivo original .bashrc ...."
		read -t 3
	fi
}


#-----------------------------------------------------------------------
# Confere se atual PS1 e diferente do q esta gravado.
#-----------------------------------------------------------------------
function __chk_last_ps1() {
	local ps1_atual ps1_last 

	# armazena a PS1 em andamento, escolhida.
	ps1_atual="$1" 

	# Vai na funcao.
	ps1_last=$(__ps1_last) 
	
	if [[ "$ps1_last" == "$ps1_atual" ]]; then
		# Nao fara atualizacao.
		UPDATE_PS1_SELECTED=FALSE
		echo " Escolheu a mesma opção que estava antes. "
		read -t 3
		return 
	else
		UPDATE_PS1_SELECTED=TRUE
		echo " Atualização em andamento...  " 
		read -t 3
		return 
	fi
}

#-----------------------------------------------------------------------
# Salvar o old movendo de last.
#-----------------------------------------------------------------------
__save_ps1_old() {
	local file_last_ps1 file_old_ps1 ps1_atual

	ps1_atual="$1"

	file_last_ps1="$DIR_PROMPT_PS1/last_ps1.ps1"

	file_old_ps1="$DIR_PROMPT_PS1/old_ps1.ps1"

	[ ! -f "$file_last_ps1" ] && echo "$ps1_atual" > "$file_last_ps1" 

	cp "$file_last_ps1" "$file_old_ps1"

}	

#-----------------------------------------------------------------------
# Gravando a PS1 escolhida. 
# So apois de mover last para old.
#-----------------------------------------------------------------------
__save_ps1_atual() {

	local file_last_ps1 file_old_ps1 ps1_atual

	ps1_atual="$1"

	# Salva atual. 
	DIR_PROMPT_PS1=$HOME/.prompt/PS1
	[ -d "$DIR_PROMPT_PS1" ] || mkdir -p $DIR_PROMPT_PS1
	file_last_ps1="$DIR_PROMPT_PS1/last_ps1.ps1"

	# Gera o arquivo com a última PS1 em andamento.
	echo "$ps1_atual" > "$file_last_ps1" 
}


#-----------------------------------------------------------------------
# Candidate to be removed from time to time if it keeps changing your prompt too much
#-----------------------------------------------------------------------
__save_bkp_log() {
	local bkp_config_files 

	bkp_config_files=$CONFIG_FILE.bak.$(date "+%Y%m%d%H%M%S")
	bkp_logs="${DIR_PROMPT_BKP}/${bkp_config_files}"

	cp "${MY_BASH_RC}" "${bkp_logs}"
}



#-----------------------------------------------------------------------
# It is important to understand what is being done here.
#-----------------------------------------------------------------------
__save_local_install() {
	local file_intalled file_in_use serial_install 	

	file_intalled="${DIR_PROMPT_INSTALL}/${MY_SCRIPT}"
	file_in_use="$BASH_SOURCE"

	# Gerando um número qualquer para servir de serial. 
	__name=$(shuf -i 2000-23233650453453500 -n 1)'_serial_prompt_install'
	serial_install="${DIR_PROMPT_INSTALL}/serial_number"

	if [  ! -f "$file_intalled" ]; then
		echo " Nao achou o install, copiando ... "
		cp "${file_in_use}" "${file_intalled}"
		read -t 3
	fi 

	# Gravando o pseudo serial
	if [  ! -f "$serial_install" ]; then
		echo " Nao tinha serial, gerando $__name... "
		echo "$__name" > "${serial_install}" 
		read -t 3
	fi
}

#-----------------------------------------------------------------------
# Try to read serial number. If not, create a new one.
#-----------------------------------------------------------------------
__pega_serial() {
	local serial_install

	serial_install="${DIR_PROMPT_INSTALL}/serial_number"
	if [  ! -f "$serial_install" ]; then

		# Se não tiver serial, vai gravar agora. 
		__save_local_install		
	
	fi

	# Var Global.
	INSTALL_serial_number=$(cat "${serial_install}")
}

#-----------------------------------------------------------------------
# ok usada. 
# Retorna a ultima ps1 gravada.
#-----------------------------------------------------------------------
__ps1_last() {
	local file_last
	DIR_PROMPT_PS1=$HOME/.prompt/PS1
	file_last_ps1="$DIR_PROMPT_PS1/last_ps1.ps1"
	[ ! -f "$file_last_ps1" ] && echo " " > "$file_last_ps1" 
	file_last=$(cat "$file_last_ps1")
	echo "$file_last"
	return 0
}	

#-----------------------------------------------------------------------
# Alterando seu bashrc...
#-----------------------------------------------------------------------
__altera_bashrc() {
	local meusource ps1_escolhida tmp_file _limar conteudo
	
	ps1_escolhida="$1"

	# vamos filtrar usando o serial.	
	#	INSTALL_serial_number
	# pegar o bashrc enviando para temporario.
	# add no fim do temporario as infos. 
	# copiar tmp para dentro do bashrc
	# reload do bashrc * Não deu certo, só fora do script.

	tmp_file="/tmp/prompt.bashrc.$INSTALL_serial_number"

	cp "${MY_BASH_RC}" "${tmp_file}"

	# Movendo as linhas se tiver o serial. 
	sed -i "/$INSTALL_serial_number/d"  "${tmp_file}"
	
	# EXPERIMENTAL 
	# Forcei a barra pq estava falhando. No dia a dia dara certo.
	sed -i '/serial_prompt_install/d'  "${tmp_file}"

	# incluir o #PS1 e source
	# Aqui tem que analisar para alterar.  
	echo '#PS1="'"${ps1_escolhida}"'"'' #'"${INSTALL_serial_number}" >> "${tmp_file}"

	FILE_INSTALLED="${DIR_PROMPT_INSTALL}/${MY_SCRIPT}"

	meusource='source '"${FILE_INSTALLED}"' '"${NUMERO_CONFIG}"' #'"${INSTALL_serial_number}"

	echo "$meusource" >> "${tmp_file}"

	cp  "${tmp_file}" "${MY_BASH_RC}"

	printf "${FILE_INSTALLED}\n"
	# FIM FIM FIM 

}

#-----------------------------------------------------------------------
# End functions
#-----------------------------------------------------------------------

#-----------------------------------------------------------------------
# Loop principal do script. 
# : TODO: Estudar forma para diminuir conteúdo. 
#-----------------------------------------------------------------------
main() {
	
clear 
__setup_terminal

if [[ "$1" == '-h' ]]; then
 __help "${FILE_INSTALLED}"
fi	

if [[ "$0" == "$BASH_SOURCE" ]]; then
	CONFIGURANDO=TRUE
else
	CONFIGURANDO=FALSE
fi


if [ $# -eq 0 ] && [ $CONFIGURANDO == "TRUE" ]; then 
	echo "- Ajuda ? digite: $0 -h "
	echo "- Escolha entre 1 a 8  "
   lista='1 2 3 4 5 6 7 8'
   exemplo="Exemplo: $0 ${RANDOM:0:1}" 
fi

for i in $lista; do
	# Definição do Tema
   case $i in
      1)
	COR_BASE=${COR[1]}  	# Vermelho
	COR_USER=${COR[3]}  	# Amarelo
	COR_ARROBA=${COR[7]}	# Branco
	COR_SERVER=${COR[6]}	# Cian
	COR_DIR=${COR[3]}		# Amarelo
	COR_HORARIO=${COR[7]}	# Branco
	COR_BATERIA=${COR[3]}	# Amarelo
	COR_CURSOR=${COR[7]}	# Branco
      ;;

      2)
	COR_BASE=${COR[5]}		# Roxo
	COR_USER=${COR[6]}		# Cian
	COR_ARROBA=${COR[3]}	# Amarelo
	COR_SERVER=${COR[4]}	# Azul
	COR_DIR=${COR[2]}		# Verde
	COR_HORARIO=${COR[7]}	# Branco
	COR_BATERIA=${COR[7]}	# Branco
	COR_CURSOR=${COR[1]}	# Vermelho
      ;;

      3)
	COR_BASE=${COR[2]}		# Verde
	COR_USER=${COR[6]}		# Cian
	COR_ARROBA=${COR[3]}	# Amarelo
	COR_SERVER=${COR[7]}	# Branco
	COR_DIR=${COR[7]}		# Branco
	COR_HORARIO=${COR[7]}	# Branco
	COR_BATERIA=${COR[7]}	# Branco
	COR_CURSOR=${COR[2]}	# Verde
      ;;

      4)
	COR_BASE=${COR[3]}		# Amarelo
	COR_USER=${COR[6]}		# Cian
	COR_ARROBA=${COR[3]}	# Amarelo
	COR_SERVER=${COR[7]}	# Branco
	COR_DIR=${COR[7]}		# Branco
	COR_HORARIO=${COR[7]}	# Branco
	COR_BATERIA=${COR[7]}	# Branco
	COR_CURSOR=${COR[2]}	# Verde
      ;;

      5)
        COR_BASE=${COR[6]}		# Cian
        COR_USER=${COR[6]}		# Cian
        COR_ARROBA=${COR[3]}	# Amarelo
        COR_SERVER=${COR[7]}	# Branco
        COR_DIR=${COR[7]}		# Branco
        COR_HORARIO=${COR[7]}	# Branco
        COR_BATERIA=${COR[7]}	# Branco
        COR_CURSOR=${COR[2]}	# Verde
      ;;

      6)
        COR_BASE=${COR[4]}		# Azul
        COR_USER=${COR[6]}		# Cian
        COR_ARROBA=${COR[3]}	# Amarelo
        COR_SERVER=${COR[7]}	# Branco
        COR_DIR=${COR[3]}		# Verde
        COR_HORARIO=${COR[7]}	# Branco
        COR_BATERIA=${COR[7]}	# Branco
        COR_CURSOR=${COR[2]}	# Verde
      ;;

      7)
	COR_BASE=${COR[7]}		# Branco
	COR_USER=${COR[3]}		# Amarelo
	COR_ARROBA=${COR[7]}	# Branco
	COR_SERVER=${COR[6]}	# Cian
	COR_DIR=${COR[3]}		# Amarelo
	COR_HORARIO=${COR[7]}	# Branco
	COR_BATERIA=${COR[3]}	# Amarelo
	COR_CURSOR=${COR[7]}	# Branco
      ;;

      8)
	COR_BASE=${COR[7]}		# Branco
	COR_USER=${COR[1]}		# Vermelho
	COR_ARROBA=${COR[7]}	# Branco
	COR_SERVER=${COR[1]}	# Vermelho
	COR_DIR=${COR[1]}		# Vermelho
	COR_HORARIO=${COR[1]}	# Vermelho
	COR_BATERIA=${COR[1]}	# Vermelho
	COR_CURSOR=${COR[7]}	# Vermelho
      ;;

      *)
	COR_BASE=${COR[1]}		# Vermelho
	COR_USER=${COR[3]}		# Amarelo
	COR_ARROBA=${COR[7]}	# Branco
	COR_SERVER=${COR[6]}	# Cian
	COR_DIR=${COR[3]}		# Amarelo
	COR_HORARIO=${COR[7]}	# Branco
	COR_BATERIA=${COR[3]}	# Amarelo
	COR_CURSOR=${COR[7]}	# Branco
      ;;

   esac;


NUMERO_CONFIG="$i"

# Partes

ANTES="${COR_BASE}${DES[0]}"

MSG="${COR[3]}[${COR[1]}${DES[2]}${COR[3]}]${CORBASE}${DES[3]}"
#ERRO='$([[ $? != 0 ]] && echo "'${MSG}'")'

USER="${COR_USER}\u"
SERVER="${COR_SERVER}\h"
SEPARADOR="${COR_BASE}${DES[3]}"
DIR="${COR_DIR}\w"
HORARIO="${COR_HORARIO}\t"

ASPAS="'"
BATERIA='['${COR_BATERIA}'$(upower -i /org/freedesktop/UPower/devices/battery_BAT0 |grep percentage | rev | cut -c 1-3 |rev)'${COR_BASE}']'
DEPOIS="\n${COR_BASE}${DES[1]}"
CURSOR="${COR_CURSOR} "'\$'" "

MEMORIA='['${COR_BATERIA}'$(free -h | grep "Mem" | tr -s " " |  cut -d" " -f4)'${COR_BASE}']'

LOADAVERAGE='['${COR_BATERIA}'$(cat /proc/loadavg | cut -d" " -f1-3)'${COR_BASE}']'

# falta o [uso cpu]

# Com Bateria, com  [uso de memória], com Horário 

PS1="${ANTES}${ERRO}${COR_BASE}[${USER}${COR_ARROBA}@${SERVER}${COR_BASE}]${SEPARADOR}${COR_BASE}[${DIR}${COR_BASE}]${SEPARADOR}[${HORARIO}${COR_BASE}]${SEPARADOR}${BATERIA}${SEPARADOR}${MEMORIA}${DEPOIS}${CURSOR}${COR[0]}"

# Com Bateria e Loadaverage

#PS1="${ANTES}${ERRO}${COR_BASE}[${USER}${COR_ARROBA}@${SERVER}${COR_BASE}]${SEPARADOR}${COR_BASE}[${DIR}${COR_BASE}]${SEPARADOR}[${HORARIO}${COR_BASE}]${SEPARADOR}${BATERIA}${SEPARADOR}${LOADAVERAGE}${DEPOIS}${CURSOR}${COR[0]}"

# Sem Bateria com Loadaverage

#PS1="${ANTES}${ERRO}${COR_BASE}[${USER}${COR_ARROBA}@${SERVER}${COR_BASE}]${SEPARADOR}${COR_BASE}[${DIR}${COR_BASE}]${SEPARADOR}[${HORARIO}${COR_BASE}]${SEPARADOR}${LOADAVERAGE}${DEPOIS}${CURSOR}${COR[0]}"

# Sem Bateria e sem Loadaverage ,com USO DE MEMORIA e com Horário.

#PS1="${ANTES}${ERRO}${COR_BASE}[${USER}${COR_ARROBA}@${SERVER}${COR_BASE}]${SEPARADOR}${COR_BASE}[${DIR}${COR_BASE}]${SEPARADOR}[${HORARIO}${COR_BASE}]${SEPARADOR}${MEMORIA}${DEPOIS}${CURSOR}${COR[0]}"

# Sem Bateria e sem Loadaverage + Horário

#PS1="${ANTES}${ERRO}${COR_BASE}[${USER}${COR_ARROBA}@${SERVER}${COR_BASE}]${SEPARADOR}${COR_BASE}[${DIR}${COR_BASE}]${SEPARADOR}[${HORARIO}${COR_BASE}]${DEPOIS}${CURSOR}${COR[0]}"

# Sem Bateria, sem loadaverage sem horário

#PS1="${ANTES}${ERRO}${COR_BASE}[${USER}${COR_ARROBA}@${SERVER}${COR_BASE}]${SEPARADOR}${COR_BASE}[${DIR}${COR_BASE}]${DEPOIS}${CURSOR}${COR[0]}"

# Sem Bateria, sem loadaverage sem horário e com USO DE MEMORIA

#PS1="${ANTES}${ERRO}${COR_BASE}[${USER}${COR_ARROBA}@${SERVER}${COR_BASE}]${SEPARADOR}${COR_BASE}[${DIR}${COR_BASE}]${SEPARADOR}${MEMORIA}${DEPOIS}${CURSOR}${COR[0]}"


	# Esta escolhendo e configurando. 
	if [ $# -eq 1 ] && [ $CONFIGURANDO == "TRUE" ]; then
		clear
		#echo 
		__info_prompt # função 
		#echo
		printf '%s\n' "${PS1@P}                                $i"

		# SO UM TESTE PRA VER SE ABREVIA. 
		# Confere qual ps1 escolheu e qual tinha.
		__chk_last_ps1 "$PS1" 
		
		if [ ${UPDATE_PS1_SELECTED} == "TRUE" ]; then
			
			__instalar_prompt "$PS1" "$NUMERO_CONFIG" # Vamos instalar se vc desejar. 
			__reset_terminal
		fi
	else
		if [ $CONFIGURANDO == "TRUE" ]; then
			printf '%s\n' "${PS1@P}                                $i"
		fi
	fi
done

if [ $CONFIGURANDO == "TRUE" ] && [ $# -eq 0 ]; then
	echo 
	echo "$exemplo"
	echo
else
	# Permite recarregar bashrc via terminal com alias.
	if ! command -v reload-prompt &> /dev/null ; then
		alias reload-prompt='source ~/.bashrc'
	fi
fi

__reset_terminal

}

	
main "$@"


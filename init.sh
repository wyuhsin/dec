#!/bin/bash

formulaes=(
	"sudo"
	"vim"
	"make"
	"gdb"
	"gcc"
	"tmux"
	"ranger"
	"go"
	"git"
)

casks=(
	"apifox"
	"chatgpt"
	"dingtalk"
	"google-chrome"
	"microsoft-remote-desktop"
	"navicat-premium"
	"omnigraffle"
	"openlens"
	"openvpn-connect"
	"orbstack"
	"paper"
	"sunloginclient"
	"tencent-lemon"
	"termius"
	"wechat"
	"wechatwork"
	"wpsoffice"
	"xmind"
)


function check_error() {
	[[ $? -ne 0 ]] && { echo "ERROR: $1 failed"; return; }
}

function install_homebrew() {
	if ! command -v brew > /dev/null 2>&1; then
		echo "INFO: homebrew is not installed, installing homebrew..."
		/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	fi

	check_error "Install homebrew"


	if [[ -r ~/.zshrc ]]; then
		echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zshrc
		. ~/.zshrc
	elif [[ -r ~/.bash_profile ]]; then
		echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.bash_profile
		. ~/.bash_profile
	elif [[ -r ~/.profile ]]; then
		echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.profile
		. ~/.profile
	elif [[ -r ~/.bashrc ]]; then
		echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.bashrc
		. ~/.bashrc
	fi

	check_error "Load homebrew enviorment variables"
}

function install_software() {
	install_command=""

	if [[ "$OSTYPE" == "darwin"* ]]; then
		install_homebrew
		install_command="brew install"

	elif [[ -f /etc/arch-release ]]; then
		sudo pacman -Syu --noconfirm
		install_command="sudo pacman -S --noconfirm"
	else
		echo "ERROR: Unsupported OS" && return
	fi


	for item in ${formulaes[@]}; do

		if command -v ${item} > /dev/null 2>&1; then
			echo "INFO: ${item} has been installed"
			continue
		fi

		${install_command} ${item}
	done

	if [[ "$OSTYPE" == "darwin"* ]]; then
		for item in ${casks[@]}; do
			if command -v ${item} > /dev/null 2>&1; then
				echo "INFO: ${item} has been installed"
				continue
			fi

			${install_command} --cask ${item}
		done
	fi
}


function main() {
	install_software
}

main



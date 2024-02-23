This is my macOs enviroment automation setup using ansible-playbook.
There are some tasks listed in the tasks folder.

- brew.yml: install necessary cli and gui
- git.yml: set up git global config
- neovim.yml install neovim and setup my custom configs
- ssh.yml copy my ssh keys to the $Home/.ssh folder, the private key is encrypted with ansible-vault
- symlink.yml: download my personal dotfiles repo and create symlinks to the home directory
- zsh.yml: install zsh and oh-my-zsh as well as some useful plugins
    

In order to run the automation, install ansible first and then run the following command:
 `ansible-playbook -v local.yml`


fx_version 'cerulean'
game 'gta5'
lua54 'yes'


author 'pm_itemswipe'
description 'item wipe out of every players inventory'
version '1.0.0'


shared_scripts {
	'@ox_lib/init.lua',
	'@es_extended/locale.lua',
    'config.lua'
}

server_script {
	'@oxmysql/lib/MySQL.lua',
	'server/gun_wipe.lua',
	'server/main.lua'
}

escrow_ignore {
	'config.lua'
  }
  
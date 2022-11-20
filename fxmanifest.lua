author 'Zenit Service'
description 'Free Relase Zenit Service Furto Veicolo '

version '1.0.0'

fx_version 'adamant'
games {'gta5'}
lua54 'yes'

server_scripts {
	'@ox_lib/init.lua',
	'config.lua',
	'server/main.lua'
}

client_scripts {
	'@ox_lib/init.lua',
	'config.lua',
	'client/main.lua'
}

escrow_ignore {
	'config.lua',
	'README.md'
}

fx_version 'cerulean'
game 'gta5'
use_experimental_fxv2_oal 'yes'
lua54 'yes'
description 'ES Extended'

version '2.0.0'

shared_scripts {
	'locale.lua',
	'locales/*.lua',
	'config.lua',
	'config.weapons.lua',
}

server_scripts {
	'@oxmysql/lib/MySQL.lua',
	'config.logs.lua',
	'server/common.lua',
	'server/modules/callback.lua',
	'server/classes/player.lua',
	'server/classes/overrides/*.lua',
	'server/functions.lua',
	'server/onesync.lua',
	'server/paycheck.lua',
	'server/main.lua',
	'server/commands.lua',
	'common/modules/*.lua',
	'common/functions.lua',
	'server/ped.lua',
	'server/modules/actions.lua'
}

client_scripts {
	'client/stancer.lua',
	'client/ped.lua',
	'client/deformation.lua',
	'client/common.lua',
	'client/functions.lua',
	'client/wrapper.lua',
	'client/modules/callback.lua',
	'client/main.lua',
	'common/modules/*.lua',
	'common/functions.lua',
	'common/functions.lua',
	'client/modules/actions.lua',
	'client/modules/death.lua',
	'client/modules/scaleform.lua',
	'client/modules/streaming.lua'
}

ui_page {
	'html/ui.html'
}

files {
	'imports.lua',
	'locale.js',
	'html/ui.html',
	'html/css/app.css',
	'html/js/mustache.min.js',
	'html/js/wrapper.js',
	'html/js/app.js',
	'html/fonts/pdown.ttf',
	'html/fonts/bankgothic.ttf',
	'html/img/accounts/bank.png',
	'html/img/accounts/black_money.png',
	'html/img/accounts/money.png'
}

dependencies {
	'/native:0x6AE51D4B',
	'oxmysql',
	'spawnmanager',
}

game 'rdr3'
fx_version "adamant"
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'
lua54 'yes'

description 'A powerful developer utility for Redm'
author 'BCC Team'
name 'bcc-utils'

shared_scripts {
    'config.lua',
    'shared/data/*.lua',
    'shared/helpers/*.lua',
    'shared/services/compression.lua',
    'shared/services/sha.lua',
    'shared/services/crypt.lua',
    'shared/services/*.lua',
    'shared/main.lua'
}

server_scripts {
    "@oxmysql/lib/MySQL.lua",
    'server/helpers/*.lua',
    'server/services/*.lua',
    'server/main.lua'
}

client_scripts {
    'client/services/*.lua',
    'client/main.lua'
}

files {
    'ui/*',
    'ui/vendor/*',
    'ui/vendor/vue-youtube/*',
}

ui_page 'ui/index.html'

dependencies {
    'oxmysql'
}

version '1.3.0'

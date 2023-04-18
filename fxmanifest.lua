game 'rdr3'
fx_version "adamant"
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

lua54 'yes'

server_scripts {
    'server/main.lua',
    'server/services/*.lua'
}

client_scripts {
    'client/main.lua',
    'client/services/*.lua',
}

files {
    'ui/*',
    'ui/vendor/*',
    'ui/vendor/vue-youtube/*',
}

ui_page 'ui/index.html'

version '1.0.0'
fx_version 'cerulean'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'
game 'rdr3'

name 'rex-mining'
author 'RexShackGaming'
description 'Mining system for RSG Framework'
version '2.1.4'
url 'https://discord.gg/YUV7ebzkqs'

shared_scripts {
    '@ox_lib/init.lua',
    'shared/config.lua',
}

server_scripts {
    'server/server.lua'
}

client_scripts {
    'client/client.lua',
    'client/workshop.lua'
}

dependencies {
    'rsg-core',
    'ox_lib',
}

files {
  'locales/*.json'
}

lua54 'yes'

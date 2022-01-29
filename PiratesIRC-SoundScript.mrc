;Pirates-IRC Sound Script
;A mIRC/AdiIRC script used to enable sounds for the PiratesIRC game.
;   - plays sounds during certain game events
;   - i.e. <~CaptJack> ☠ Cap'n 👑 Jack_Sparrow not be saved n' loses 1 power as he swims to the ship! 🎵drowned🎵
;
;https://piratesirc.com/
;https://github.com/PiratesIRC/PiratesIRC-Sound-Script/
;
;Requirements:
;     - Crewmember on a ship - https://piratesirc.com/play.html
;     - mIRC (www.mirc.com) or AdiIRC (www.adiirc.com)
;
;Directions:
;   1) Download the sound pack at https://piratesirc.com/sounds/sounds.zip
;   2) Put sounds.zip in your client's sounds directory or a directory of your choice
;   3) Load the code below within mIRC/AdiIRC:
;      a) Press ALT + R
;         - If using mIRC, select the Remote tab
;         - if using AdiIRC, select Editors, Edit Scripts
;      b) Copy and paste the code below
;      c) Press OK
;      d) Setup the script
;       - Type /PiratesIRC-Sounds.setup
;       - OR access by right clicking -> Pirates-IRC Sounds, Settings, Run Full Setup
;         - Sounds.zip will be automatically extracted once setup is complete
;   4) Test by typing !Pirates Sound Test within the PiratesIRC game channel
;
;-------------------------------- START OF CODE, copy + paste into your IRC Client Script Editor --------------------------------
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
; PiratesIRC-Sound Script for mIRC/AdiIRC
; www.piratesirc.com
; Access via the menubar, Commands
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
alias PiratesIRC-Sound.version return 0.30
alias PiratesIRC-Sound.NumberofFilesinZip return 138
alias PiratesIRC-Sounds.website return https://pastebin.com/TW7kcY5J
on 1:LOAD:{
  PiratesIRC-Sounds.setup
  write -c PiratesIRC-sounds.log
}
on 1:UNLOAD:{
  if ($dialog(pircs.md)) dialog -x pircs.md
  .remove piratesirc-sounds.dat
  unset %piratesirc-sounds.*
  echo -a 🕱🎵 PiratesIRC Sounds Uninstalled 😥
}
on 1:START:/.PiratesIRC-Sounds.VesionCheck
alias PiratesIRC-Sounds.setup {
  ;/PiratesIRC-Sounds.setup - asks for input to setup the script
  if ($dialog(pircs.md)) dialog -x pircs.md
  if (!$exists(PiratesIRC-sounds.log)) write -c PiratesIRC-sounds.log
  set %piratesirc-sounds.network $input(IRC Network PiratesIRC is on. $+ $crlf $+ Enter * for all networks.,qe,PiratesIRC-Sounds Network,$network)
  if (!%piratesirc-sounds.network) { noop $input(Setup Cancelled!,wo,PiratesIRC-Sounds) | return }
  set %piratesirc-sounds.channel $input(Enter the Channel PiratesIRC is located on:,e,PiratesIRC-Sounds,#pirates)
  if (!%piratesirc-sounds.channel) { noop $input(Setup Cancelled!,wo,PiratesIRC-Sounds) | return }
  set %piratesirc-sounds.bot $input(Enter the PiratesIRC bot's nickname:,e,PiratesIRC-Sounds,CaptainJack)
  if (!%piratesirc-sounds.bot) { noop $input(Setup Cancelled!!,wo,PiratesIRC-Sounds) | return }
  set %piratesirc-sounds.directory $sdir($sound(mp3),Location of PiratesIRC Sounds)
  if (!%piratesirc-sounds.directory) { noop $input(Setup Cancelled!!,wo,PiratesIRC-Sounds) | return }
  if ($input(Attempt to download missing files when triggered?,qy,PiratesIRC-Sounds)) set %piratesirc-sounds.download $ifmatch
  if ($input(Mute on away?,qy,PiratesIRC-Sounds)) set %piratesirc-sounds.muteonaway $ifmatch
  if ($input(Mute on Do Not Disturb?,qy,PiratesIRC-Sounds)) set %piratesirc-sounds.muteonDnD $ifmatch
  var %a $input(Enable Pirates-IRC Sounds?,qy,PiratesIRC-Sounds)
  .PiratesIRC-Sounds.enabled.toggle %a
  inc %piratesirc-sounds.setup 1
  unset %piratesirc-sounds.*.sounds.DISABLED
  unset %piratesirc-sounds.file.disabled.*
  echo -a 
  echo -a 🕱🎵 PiratesIRC Sounds settings 🕱🎵
  echo -a $tab Status: $iif(%piratesirc-sounds.enabled,3Enabled,4Disabled) - Channel: $iif(%piratesirc-sounds.channel, $+ $ifmatch,4none) - Bot Nickname: $iif(%piratesirc-sounds.bot, $+ $ifmatch,4none) - Directory: $iif(%piratesirc-sounds.directory, $+ $ifmatch,4none)
  echo -a $tab Download missing files: $iif(%piratesirc-sounds.download,3Enabled,4Disabled) -  Mute on Away: $iif(%piratesirc-sounds.muteonaway,3Enabled,4Disabled) - Mute on Do Not Disturb: $iif(%piratesirc-sounds.muteonDnD,3Enabled,4Disabled)
  echo -a 
  PiratesIRC-Sounds.WriteLog Full setup complete: Enabled? %piratesirc-sounds.enabled - %piratesirc-sounds.bot on %piratesirc-sounds.channel - %n files in %piratesirc-sounds.directory - download? %piratesirc-sounds.download - away mute? %piratesirc-sounds.muteonaway - DND mute? %piratesirc-sounds.muteonDnD
  .PiratesIRC-Sound.ExtractZip
  var %n $findfile(%piratesirc-sounds.directory,*.mp3,0,1)
  if (%n <= 45) echo -a Sound files are missing! Download the sound pack at 12https://piratesirc.com/sounds/sounds.zip and extract to $iif(%piratesirc-sounds.directory, $+ %piratesirc-sounds.directory,the sounds directory specified in /PiratesIRC-Sounds.setup)
  else echo -a %n sounds found in %piratesirc-sounds.directory $+ ! You can perform a sound test in %piratesirc-sounds.channel with !Pirates Sound Test
  PiratesIRC-Sounds.VesionCheck
  PiratesIRC-Sounds.Dialog.Open
}
alias PiratesIRC-Sounds.enabled.toggle {
  ;/PiratesIRC-Sounds.enabled.toggle - enables/disables sounds
  if (!$1) {
    set %piratesirc-sounds.enabled 0 
    .disable #PiratesIRC-Sounds
    if ($show) echo -a 🕱🎵 PiratesIRC Sounds - 4Disabled
  }
  else {
    var %error
    if (!%piratesirc-sounds.channel) set %error Channel is not set!
    if (!%piratesirc-sounds.bot) set %error Bot's Nickname is not set!
    if (!%piratesirc-sounds.directory) set %error Sounds Directory is not set!
    if (%error) echo -a 4PiratesIRC-Sounds Error: %error Run Setup! /PiratesIRC-Sounds.setup
    else {
      set %piratesirc-sounds.enabled 1
      .enable #PiratesIRC-Sounds
      if ($show) echo -a 🕱🎵 PiratesIRC Sounds - 3Enabled
    }
  }
}
alias PiratesIRC-Sound.ExtractZip {
  ;/PiratesIRC-Sound.ExtractZip - if sounds.zip exists in sound dir, extracts + overwrites
  var %r, %file %piratesirc-sounds.directory $+ sounds.zip
  if ($exists(%file)) set %r $zip(%file,eo,%piratesirc-sounds.directory)
  if ($show) && (%r) {
    var %n $findfile(%piratesirc-sounds.directory,*.mp3,0)
    var %msg %n sound files have been extracted and ready for use!
    if ($dialog(pircs.md)) {
      did -ra pircs.md 4 %msg
      PiratesIRC-Sounds.Dialog.PopulateSounds
    }
    else echo -a 🕱🎵 PiratesIRC Sounds - %msg
  }
  else {
    var %msg Unable to extract Sounds.zip! Download from https://piratesirc.com/sounds/sounds.zip
    if ($dialog(pircs.md)) {
      did -b pircs.md 328
      did -e pircs.md 327
      did -ra pircs.md 4 %msg
    }
    else echo -a %msg
  }
  .timer 1 1 .remove -b %file
}
alias PiratesIRC-Sounds.DownloadFile {
  ;/PiratesIRC-Sounds.DownloadFile <file> - attempts to download any missing sound files
  if (%piratesirc-sounds.download.failed.cooldown) || (!%piratesirc-sounds.download) || (!$1) return
  var %file $nopath($1-) $+ .mp3
  if ($exists(" $+ %piratesirc-sounds.directory $+ %file $+ .mp3 $+ ")) return
  var %url https://piratesirc.com/sounds/ $+ %file
  if (%url isnum) { 
    if ($urlget(%url).state == fail) {
      var %e Unable to download %file!
      if (%piratesirc-sounds.debug) echo 4 -at PiratesIRC-Sounds Download Error: %e
      PiratesIRC-Sounds.WriteLog %e
      set -u3600 %piratesirc-sounds.download.failed.cooldown %e
      return
    }
  }
  else {
    var %a $urlget(%url,gfi,%piratesirc-sounds.directory,PiratesIRC-Sounds.FileDownloaded $gettok(%file,1,32))
    if (!%a) {
      var %e Unable to download %file Code: %a
      PiratesIRC-Sounds.WriteLog %e
      if (%piratesirc-sounds.debug) echo 4 -at PiratesIRC-Sounds Download Error: %e
      set -u3600 %piratesirc-sounds.download.failed.cooldown %e
    }
  }
}
alias PiratesIRC-Sounds.FileDownloaded {
  ;/PiratesIRC-Sounds.FileDownloaded <file> - download was successful
  if ($1) {
    PiratesIRC-Sounds.WriteLog Downloaded $1
    PiratesIRC-Sounds.PlaySound download $1
    inc %piratesirc-sounds.stats.downloads
  }
}
alias PiratesIRC-Sounds.WriteLog {
  if (%piratesirc-sounds.DisableLog) return
  var %t ( $+ $date $time $+ )
  write -il1 PiratesIRC-sounds.log %t $1-
  if ($dialog(pircs.md)) did -i pircs.md 431 1 %t $1-
  if ($lines(PiratesIRC-sounds.log) > 100) write -d PiratesIRC-sounds.log
}
alias PiratesIRC-Sounds.VesionCheck {
  ;/PiratesIRC-Sounds.VesionCheck - checks for new version of script
  if (%piratesirc-sounds.versioncheck.cooldown) return
  if ($show) WebsiteDataTester $PiratesIRC-Sounds.website
  else .WebsiteDataTester $PiratesIRC-Sounds.website
  set -u7200 %piratesirc-sounds.versioncheck.cooldown 1
}
 
;https://forums.mirc.com/ubbthreads.php/topics/269401/re-youtube-link-to-title-for-mirc#Post269401
alias -l WebsiteDataTester { noop $urlget($1-,gb,& $+ $ticks,$iif($show,ScrapeWebsiteData,.ScrapeWebsiteData)) }
alias -l ScrapeWebsiteData { 
  var %b = $urlget($1).target
  if ($bfind(%b,1,/<title>(.*)<\/title>/i,Title).regex) { var %title = $regml(Title,1) }
 
  ;modified for PiratesIRC Sound Script
  var %msg
  var %remote.ver $remove($wildtok(%title,v*,1,32),v)
  if (%remote.ver > $PiratesIRC-Sound.version) {
    echo -a A new version of the PiratesIRC-Sound Script $paren(%remote.ver) is available at $PiratesIRC-Sounds.website
    if ($dialog(pircs.md)) did -ra pircs.md 4 New version $paren(%remote.ver) available!
    PiratesIRC-Sounds.WriteLog New version available: %remote.ver Local version is $PiratesIRC-Sound.version
    .timer 1 3 url $PiratesIRC-Sounds.website
  }
  else {
    set %msg You have the latest version of PiratesIRC Sound Script $paren($PiratesIRC-Sound.version)
    if ($show) echo -a %msg
    if ($dialog(pircs.md)) did -ra pircs.md 4 %msg
    PiratesIRC-Sounds.WriteLog Version check - no updates
  }
}
 
alias PiratesIRC-Sounds.filtersoundfile {
  ;$PiratesIRC-Sounds.filtersoundfile(text) - returns the sound
  var %t $strip($1-)
  var %file $remove($gettok(%t,$calc($numtok(%t,55356) - 1),55356),�,🎵)
  if ($regsub(removeinvalids,%file,[^a-zA-Z0-9]+,,%file)) return %file
}
alias PiratesIRC-Sounds.PlaySound {
  ;/PiratesIRC-Sounds.PlaySound <method/source> <file name> - plays sound
  if (!%piratesirc-sounds.enabled) return
  if (%piratesirc-sounds.muteonDnD) && ($donotdisturb) return
  if (%piratesirc-sounds.muteonaway) && ($away) return
  if (!$2) return
  var %source $1
  var %file $remove($2,.mp3)
  if (%source == download) set %file $remove($2,.mp3)
  if (%file) {
    var %f $nopath(%file)
    if (%source == Channel) && (%piratesirc-sounds.channel.sounds.DISABLED) { PiratesIRC-Sounds.WriteLog %source sounds have been DISABLED - %f triggered by $nick | return }
    if (%source == Private) && (%piratesirc-sounds.private.sounds.DISABLED) { PiratesIRC-Sounds.WriteLog %source sounds have been DISABLED - %f triggered by $nick | return }
    if ($eval($+(%,piratesirc-sounds.file.disabled.,%f),2)) { PiratesIRC-Sounds.WriteLog %f has been DISABLED - triggered by $nick / %source | return }
 
    set %file " $+ %piratesirc-sounds.directory $+ %file $+ .mp3 $+ "
    if ($exists(%file)) {
      if (%piratesirc-sounds.debug) echo -st play file: %file
      PiratesIRC-Sounds.WriteLog $nick %source triggered sound: %f
      if ($dialog(pircs.md)) did -ra pircs.md 4 Playing: $remove($nopath(%f),.mp3)
      .splay -p %file
      inc %piratesirc-sounds.stats.played
    }
    else {
      set %file $remove($nopath(%file),.mp3)
      if (%piratesirc-sounds.debug) echo -st %file does not exist!
      if (%piratesirc-sounds.download) PiratesIRC-Sounds.DownloadFile %file
      PiratesIRC-Sounds.WriteLog %file does not exist! $iif(%piratesirc-sounds.download,Attempting to download...)
    }
  }
}
 
#PiratesIRC-Sounds on
on 1:TEXT:*🎵*:%piratesirc-sounds.channel:{
  ;channel messages
  if ($chr(37) isin $1-) || ($chr(36) isin $1-) return
  if (%piratesirc-sounds.bot !iswm $nick) return
  if (%piratesirc-sounds.network) && (%piratesirc-sounds.network !iswm $network) return
  if (!%piratesirc-sounds.enabled) || (!%piratesirc-sounds.channel) || (!%piratesirc-sounds.bot) || (!%piratesirc-sounds.directory) return
  if ($PiratesIRC-Sounds.filtersoundfile($1-)) { PiratesIRC-Sounds.PlaySound Channel $ifmatch | inc %piratesirc-sounds.stats.channelsounds }
}
on 1:TEXT:*🎵*:?:{
  ;private messages
  if (%piratesirc-sounds.bot != $nick) return
  if ($chr(37) isin $1-) || ($chr(36) isin $1-) return
  if (%piratesirc-sounds.bot !iswm %piratesirc-sounds.bot) return
  if (%piratesirc-sounds.network) && (%piratesirc-sounds.network !iswm $network) return
  if (!%piratesirc-sounds.enabled) || (!%piratesirc-sounds.bot) || (!%piratesirc-sounds.directory) return
  if ($PiratesIRC-Sounds.filtersoundfile($1-)) { PiratesIRC-Sounds.PlaySound Private $ifmatch | inc %piratesirc-sounds.stats.privatesounds }
}
on 1:NOTICE:*🎵*:?:{
  ;private notices
  if (%piratesirc-sounds.bot != $nick) return
  if ($chr(37) isin $1-) || ($chr(36) isin $1-) return
  if (%piratesirc-sounds.bot !iswm $nick) return
  if (%piratesirc-sounds.network) && (%piratesirc-sounds.network !iswm $network) return
  if (!%piratesirc-sounds.enabled) || (!%piratesirc-sounds.bot) || (!%piratesirc-sounds.directory) return
  if ($PiratesIRC-Sounds.filtersoundfile($1-)) { PiratesIRC-Sounds.PlaySound Private $ifmatch | inc %piratesirc-sounds.stats.privatesounds }
}
#PiratesIRC-Sounds end
 
menu menubar,status,channel,nicklist {
  ;Access the menu via IRC Client's Command's menu
  PiratesIRC Sounds
  .Dialog:/PiratesIRC-Sounds.Dialog.Open
  .-
  .Status - $iif(%piratesirc-sounds.enabled,Enabled,Disabled):/PiratesIRC-Sounds.enabled.toggle $iif(%piratesirc-sounds.enabled,0,1)
  .-
  ..Settings
  ..Run Full Setup:/PiratesIRC-sounds.setup
  ..-
  ..Network - %piratesirc-sounds.network : { $iif($network && $input(Set Network to $network $+ ?,wy,PiratesIRC-Sounds),set % $+ piratesirc-sounds.network $network,noop) }
  ..Channel - %piratesirc-sounds.channel : { $iif($chan && $input(Set Channel to $chan $+ ?,wy,PiratesIRC-Sounds),set % $+ piratesirc-sounds.channel $chan,noop) }
  ..Bot Nickname - %piratesirc-sounds.bot : { $iif($1 && $input(Set Bot to $1 $+ ?,wy,PiratesIRC-Sounds),set % $+ piratesirc-sounds.bot $1,noop) }
  ..-
  ..$iif(!%piratesirc-sounds.versioncheck.cooldown,Check for new version):/PiratesIRC-Sounds.VesionCheck
  .-
  .$iif($insong,Stop Current Sound - $remove($nopath($insong.fname),.mp3)):/splay stop
  .-
  .-
  .View Log:/run PiratesIRC-sounds.log
}
alias PiratesIRC-Sounds.Dialog.Open {
  var %dlg pircs.md
  if ($dialog(%dlg)) dialog -e %dlg
  else {
    inc %piratesirc-sounds.stats.dialog
    dialog -mad %dlg %dlg
  }
}
dialog pircs.md {
  title ""
  size -1 -1 278 125
  option dbu
  tab "Main", 100, 3 3 271 102
  button "Check for new version", 101, 8 89 90 12, tab 100
  check "Enabled", 102, 8 24 50 10, tab 100
  button "Uninstall", 103, 204 89 64 12, tab 100
  edit "", 105, 6 35 262 50, tab 100 read multi return autovs vsbar
  button "Run Full Setup", 106, 202 21 65 12, tab 100
  button "Stop Current Sound", 107, 106 89 90 12, hide tab 100
  tab "Settings", 200
  combo 205, 50 23 60 86, tab 200 sort size edit drop
  text "Network:", 206, 8 24 40 8, tab 200
  text "Channel:", 207, 8 36 40 8, tab 200
  text "Bot Name:", 208, 8 45 40 8, tab 200
  check "Auto-download missing files", 209, 8 56 100 10, tab 200
  check "Mute on /away", 210, 8 67 100 10, tab 200
  text "Sounds Directory:", 211, 8 93 58 8, tab 200
  button "None", 212, 68 91 200 12, tab 200
  edit "", 213, 50 35 60 10, tab 200 center
  check "Mute on /dnd (Do Not Disturb)", 215, 8 78 120 10, tab 200
  edit "", 214, 50 45 60 10, tab 200 center
  box "Play Sounds Received by:", 216, 158 24 110 44, tab 200
  check "Channel", 217, 166 36 96 10, tab 200
  check "Private Msg/Notice", 218, 166 50 96 10, tab 200
  tab "Sounds", 300
  button "Download Sounds Archive", 327, 176 72 94 12, tab 300
  button "Extract Sounds Archive", 328, 176 88 94 12, tab 300
  button "Open Sounds Directory", 305, 176 22 94 12, disable tab 300
  list 302, 8 30 68 70, tab 300 sort size vsbar
  list 307, 99 31 68 70, tab 300 size
  text "Enabled Sounds", 301, 8 22 68 8, tab 300 center
  text "Disabled Sounds", 306, 99 22 68 8, tab 300 center
  button ">", 303, 80 46 16 12, tab 300
  button "<", 304, 80 66 16 12, tab 300
  tab "Log", 400
  check "Enable Log", 430, 8 24 50 10, tab 400
  edit "", 431, 4 35 267 68, tab 400 read multi vsbar
  button "Clear", 432, 232 22 37 12, tab 400
  button "OK", 1, 236 110 37 12, default ok
  link "PiratesIRC.com", 2, 4 112 60 8
  button "?", 3, 224 110 10 12, hide
  text "", 4, 65 112 156 8, center
}
 
on 1:dialog:pircs.md:init:0:{
  if (%piratesirc-sounds.network) && (%piratesirc-sounds.channel) && (%piratesirc-sounds.bot) set %piratesirc-sounds.setup 1
  if (%piratesirc-sounds.enabled) did -c $dname 102
  dialog -t $dname PiratesIRC Sounds v $+ $PiratesIRC-Sound.version
  if (%piratesirc-sounds.versioncheck.cooldown) did -b $dname 101
  var %f piratesirc-sounds.dat 
  write -c %f 
  write %f 🕱 🎵 Welcome to the PiratesIRC Sounds Script v $+ $PiratesIRC-Sound.version $+ ! 🎵 🕱 $crlf  ​
  write %f Settings tab - Settings for Network, Channel, and Playing Sounds $crlf $+ Sounds tab - Download, Extract, and enabled/disable individual sounds $crlf $+ Log tab - View list of recent events $crlf  ​
  write %f Test by typing !P Sound Test on $iif(%piratesirc-sounds.channel,$upper(%piratesirc-sounds.channel),the game channel) $crlf $+ - - - If having issues, Run Full Setup - - - $crlf  ​
  write %f Stats:
  write %f Sounds played: $iif(%piratesirc-sounds.stats.played,%piratesirc-sounds.stats.played,0)
  write %f Sounds played via Channel: $iif(%piratesirc-sounds.stats.channelsounds,%piratesirc-sounds.stats.channelsounds,0)
  write %f Sounds played via Private: $iif(%piratesirc-sounds.stats.privatesounds,%piratesirc-sounds.stats.privatesounds,0)
  write %f Sounds downloaded: $iif(%piratesirc-sounds.stats.downloads,%piratesirc-sounds.stats.downloads,0)
  write %f This dialog has been opened %piratesirc-sounds.stats.dialog times!
  loadbuf -o $dname 105 %f
 
  ;tab 200 Settings
  ;populate networks
  if (%piratesirc-sounds.network != *) did -a $dname 205 *
  var %t $scon(0)
  if (!%t) {
    did -a $dname 205 %piratesirc-sounds.network
    did -c $dname 205 1
  }
  else {
    var %n, %a *
    var %i 0
    while (%t > %i) {
      inc %i
      set %n $scon(%i).network
      if (%n == %piratesirc-sounds.network) continue
      set %a $addtok(%a,%n,44)
      if (%n) did -a $dname 205 %n
    }
    if (%piratesirc-sounds.network) {
      if (!$findtok(%a,%piratesirc-sounds.network,0,44)) did -a $dname 205 %piratesirc-sounds.network
      elseif (%piratesirc-sounds.network != $did(205).seltext) did -a $dname 205 %piratesirc-sounds.network
    }
    if (%piratesirc-sounds.network) {
      var %i 0
      while ($did(205).lines > %i) {
        inc %i
        did -c $dname 205 %i
        if (%piratesirc-sounds.network) && ($did(205).seltext == %piratesirc-sounds.network) break
      }
    }
  }
  did -ra $dname 213 %piratesirc-sounds.channel
  did -ra $dname 214 %piratesirc-sounds.bot
  if (%piratesirc-sounds.download) did -c $dname 209
  if (%piratesirc-sounds.muteonaway) did -c $dname 210
  if (%piratesirc-sounds.muteonDnD) did -c $dname 215
  did -c $dname 217,218
  if (%piratesirc-sounds.channel.sounds.DISABLED) did -u $dname 217
  if (%piratesirc-sounds.privatesounds.sounds.DISABLED) did -u $dname 218
  did -ra $dname 212 $iif(%piratesirc-sounds.directory,$ifmatch,None)
  ;tab 300 Sounds
  unset %piratesirc-sounds.temp.dlgtab300
  if (%piratesirc-sounds.directory) did -e $dname 305
  if ($findfile(%piratesirc-sounds.directory,sounds.zip,0)) {
    did -e $dname 328
    did -b $dname 327
    .timer 1 0 did -ra $dname 4 Sounds.zip found! Extract using the button in the Sounds tab...
  }
  else {
    var %n $calc($did(302).lines + $did(307).lines)
    if (%n >= $PiratesIRC-Sound.NumberofFilesinZip) did -b $dname 327
    else did -e $dname 327
    did -b $dname 328
  }
  ;tab 400 Log
  if (!%piratesirc-sounds.DisableLog) did -c $dname 430
  did -r $dname 431
  if ($exists(PiratesIRC-sounds.log)) loadbuf -pio $dname 431 PiratesIRC-sounds.log
 
  if ($insong) {
    did -ra $dname 4 Playing: $remove($nopath($insong.fname),.mp3)
    did -v $dname 107
  }
  else {
    var %n $findfile(%piratesirc-sounds.directory,*.mp3,0,1)
    if (%n) did -ra $dname 4 %n sound files found and ready for use!
    else did -ra $dname 4 No sounds found! Download via the Sounds tab, Download Archive
  }
  if (!%piratesirc-sounds.setup) {
    .timer 1 1 did -ra $dname 4 Setup has not been completed! Click 'Run Full Setup'
    did -f $dname 106
  }
}
on 1:dialog:pircs.md:Sclick:2:url http://www.piratesirc.com
on 1:dialog:pircs.md:Sclick:3:did -ra $dname 4 Right click on any option for a description
on 1:dialog:pircs.md:Sclick:101:{
  did -ra $dname 4 Checking for new version...
  .PiratesIRC-Sounds.VesionCheck
  did -b $dname 101
}
on 1:dialog:pircs.md:Sclick:102:{
  set %piratesirc-sounds.enabled $iif($did(102).state,1,0)
  did -ra $dname 4 PiratesIRC Sounds: $iif(%piratesirc-sounds.enabled,Enabled 🥳,Disabled ☹)
}
on 1:dialog:pircs.md:Sclick:103:{
  dialog -i $dname
  var %a $input(Are you sure you want to uninstall PiratesIRC Sounds?,wybg,Uninstall)
  if (%a) .timer 1 0 unload -rs $script
  else dialog -e $dname
}
on 1:dialog:pircs.md:Sclick:106:{
  dialog -i $dname
  var %a $input(Are you sure you want to re-run the Setup? $crlf $+ This will reset all options but may correct issues from sounds playing.,qybg,Run Full Setup?)
  if (%a) { dialog -x $dname | PiratesIRC-Sounds.setup }
  else dialog -e $dname
}
on 1:dialog:pircs.md:Sclick:107:{
  var %f $remove($nopath($insong.fname),.mp3)
  splay stop
  did -ra $dname 4 Stopped sound: %f
  did -h $dname 107
}
on 1:dialog:pircs.md:edit:205:if ($did(205)) { set %piratesirc-sounds.network $ifmatch | did -ra $dname 4 Network set to $ifmatch }
on 1:dialog:pircs.md:Sclick:205:if ($did(205).seltext) { set %piratesirc-sounds.network $ifmatch | did -ra $dname 4 Network set to $ifmatch }
on 1:dialog:pircs.md:Sclick:209:{
  set %piratesirc-sounds.download $iif($did(209).state,1,0)
  did -ra $dname 4 Missing files will $iif(%piratesirc-sounds.download,be download,NOT be downloaded) when triggered
}
on 1:dialog:pircs.md:Sclick:210:{
  set %piratesirc-sounds.muteonaway $iif($did(210).state,1,0)
  did -ra $dname 4 All sounds will $iif(%piratesirc-sounds.muteonaway,be MUTED,PLAY) when you are /AWAY
}
on 1:dialog:pircs.md:edit:214:{
  if ($did(214)) {
    set %piratesirc-sounds.bot $ifmatch
    did -ra $dname 4 Bot nickname set to $ifmatch
  }
}
on 1:dialog:pircs.md:Sclick:215:{
  set %piratesirc-sounds.muteonDnD $iif($did(215).state,1,0)
  did -ra $dname 4 All sounds will $iif(%piratesirc-sounds.muteonDnD,be MUTED,PLAY) when you /DnD
}
on 1:dialog:pircs.md:Sclick:212:{
  var %dir $iif(%piratesirc-sounds.directory,$ifmatch,$mircdir)
  set %dir $sdir(%dir,Location of PiratesIRC Sounds)
  if (%dir) {
    set %piratesirc-sounds.directory %dir
    did -ra $dname 212 %dir
    var %n $findfile(%dir,*.mp3,0)
    if (%n) did -ra $dname 4 %n sounds files found!
    else did -ra $dname 4 No files found! Did you select the correct directory?
  }
  else did -ra $dname 4 $iif(%piratesirc-sounds.directory,Sound directory remains $ifmatch,No sound directory selected!)
  unset %piratesirc-sounds.temp.dlgtab300
}
on 1:dialog:pircs.md:Sclick:217:{
  set %piratesirc-sounds.channel.sounds.DISABLED $iif($did(217).state,0,1)
  did -ra $dname 4 Sounds triggered in $iif(%piratesirc-sounds.channel,$upper(%piratesirc-sounds.channel),the game channel) will $iif(%piratesirc-sounds.channel.sounds.DISABLED,INGORED,be PLAYED)
}
on 1:dialog:pircs.md:Sclick:218:{
  set %piratesirc-sounds.privatesounds.sounds.DISABLED $iif($did(218).state,0,1)
  did -ra $dname 4 Sounds triggered via Private Messages/Notices will $iif(%piratesirc-sounds.private.sounds.DISABLED,INGORED,be PLAYED)
}
on 1:dialog:pircs.md:Sclick:300:{
  var %n $var(%piratesirc-sounds.file.disabled.*,0)
  if (%n) did -ra $dname 4 %n $iif(%n == 1,sound has,sounds have) been disabled.
  if (!%piratesirc-sounds.temp.dlgtab300) { PiratesIRC-Sounds.Dialog.PopulateSounds | set %piratesirc-sounds.temp.dlgtab300 1 }
}
on 1:dialog:pircs.md:Sclick:302:{
  did -e $dname 303
  did -b $dname 304
  did -u $dname 307
}
on 1:dialog:pircs.md:Sclick:303:{
  if ($did(302).seltext) {
    set %piratesirc-sounds.file.disabled. $+ $ifmatch 1
    did -a $dname 307 $ifmatch
    did -d $dname 302 $did(302).sel
    did -ra $dname 4 Sound ' $+ $upper($ifmatch) $+ ' will no longer be played
  }
  did -b $dname 303
}
on 1:dialog:pircs.md:Sclick:307:{
  did -e $dname 304
  did -b $dname 303
  did -u $dname 302
}
on 1:dialog:pircs.md:Sclick:304:{
  if ($did(307).seltext) {
    unset %piratesirc-sounds.file.disabled. $+ $ifmatch
    did -a $dname 302 $ifmatch
    did -d $dname 307 $did(307).sel
    did -ra $dname 4 Sound ' $+ $upper($ifmatch) $+ ' will be played when triggered
  }
  did -b $dname 304
}
on 1:dialog:pircs.md:Sclick:305:run %piratesirc-sounds.directory
on 1:dialog:pircs.md:Sclick:327:{
  did -ra $dname 4 Opening browser and downloading sounds.zip
  url https://piratesirc.com/sounds/sounds.zip
  var %msg Move sounds.zip to %piratesirc-sounds.directory and Extract
  echo -a Move sounds.zip to %piratesirc-sounds.directory and Extract
  .timer 1 2 did -ra $dname 4 %msg
  .timerPiratesIRC-Sounds.Check.SoundsZip -o 0 3 PiratesIRC-Sounds.Dialog.Timer.Check.SoundsZip
}
on 1:dialog:pircs.md:Sclick:328:{
  did -ra $dname 4 Extracting Sounds.zip...
  PiratesIRC-Sound.ExtractZip
  did -b $dname 328
  unset %piratesirc-sounds.temp.dlgtab300
}
on 1:dialog:pircs.md:Sclick:430:{
  set %piratesirc-sounds.DisableLog $iif($did(430).state,0,1)
  did -ra $dname 4 Logging is $iif(%piratesirc-sounds.DisableLog,Disabled,Enabled)
}
on 1:dialog:pircs.md:Sclick:432:{
  did -r $dname 431
  write -c PiratesIRC-sounds.log
  did -ra $dname 4 Cleared log
}
on 1:dialog:pircs.md:Rclick:2:did -ra $dname 4 Opens website in your default browser
on 1:dialog:pircs.md:Rclick:102:did -r $dname 4 $iif($rand(1,2) == 1,Beep,Boop)
on 1:dialog:pircs.md:close:{
  set %piratesirc-sounds.bot $did(214)
  set %piratesirc-sounds.channel $did(213)
  .timerPiratesIRC-Sounds.Check.SoundsZip off
  unset %piratesirc-sounds.temp.dlgtab300
}
alias PiratesIRC-Sounds.Dialog.Timer.Check.SoundsZip {
  var %dlg pircs.md
  if (!$dialog(%dlg)) .timerPiratesIRC-Sounds.Check.SoundsZip off
  if ($exists(%piratesirc-sounds.directory $+ sounds.zip)) {
    did -e %dlg 328
    did -b %dlg 327
    var %msg Sounds.zip found! Extract using the button in the Sounds tab...
    echo -a %msg
    did -ra %dlg 4 %msg
    .timerPiratesIRC-Sounds.Check.SoundsZip off
  }
}
alias PiratesIRC-Sounds.Dialog.PopulateSounds {
  var %dlg pircs.md
  if (!$dialog(%dlg)) return
  var %n $findfile(%piratesirc-sounds.directory,*.mp3,0)
  if (%n >= $PiratesIRC-Sound.NumberofFilesinZip) did -b %dlg 327
  if (%n) {
    var %f, %i 0
    while (%n > %i) {
      inc %i
      set %f $remove($nopath($findfile(%piratesirc-sounds.directory,*.mp3,%i)),.mp3)
      if (!$eval(% $+ piratesirc-sounds.file.disabled. $+ %f,2)) did -a %dlg 302 %f
    }
 
    set %n $var(%piratesirc-sounds.file.disabled.*,0)
    set %i 0
    while (%n > %i) {
      inc %i
      did -a %dlg 307 $gettok($var(%piratesirc-sounds.file.disabled.*,%i),4-,46)
    }
  }
}
;-------------------------------- END OF CODE --------------------------------
 
RAW Paste Data
;Pirates-IRC Sound Script
;   - plays sounds during certain game events
;   - i.e. <~CaptJack> ☠ Cap'n 👑 Jack_Sparrow not be saved n' loses 1 power as he swims to the ship! 🎵drowned🎵
;
;https://piratesirc.com/
;https://pastebin.com/edit/TW7kcY5J
;
;Requirements:
;     - Crewmember on a ship - https://piratesirc.com/play.html
;     - mIRC (www.mirc.com) or AdiIRC (www.adiirc.com)
;
;Directions:
;   1) Download the sound pack at https://piratesirc.com/sounds/sounds.zip
;   2) Put sounds.zip in your client's sounds directory or a directory of your choice
;   3) Load the code below within mIRC/AdiIRC:
;      a) Press ALT + R
;         - If using mIRC, select the Remote tab
;         - if using AdiIRC, select Editors, Edit Scripts
;      b) Copy and paste the code below
;      c) Press OK
;      d) Setup the script
; 		- Type /PiratesIRC-Sounds.setup
; 		- OR access by right clicking -> Pirates-IRC Sounds, Settings, Run Full Setup
; 	      - Sounds.zip will be automatically extracted once setup is complete
;   4) Test by typing !Pirates Sound Test within the PiratesIRC game channel
;
;-------------------------------- START OF CODE, copy + paste into your IRC Client Script Editor --------------------------------
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
; PiratesIRC-Sound Script for mIRC/AdiIRC
; www.piratesirc.com
; Access via the menubar, Commands
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
alias PiratesIRC-Sound.version return 0.30
alias PiratesIRC-Sound.NumberofFilesinZip return 138
alias PiratesIRC-Sounds.website return https://pastebin.com/TW7kcY5J
on 1:LOAD:{
  PiratesIRC-Sounds.setup
  write -c PiratesIRC-sounds.log
}
on 1:UNLOAD:{
  if ($dialog(pircs.md)) dialog -x pircs.md
  .remove piratesirc-sounds.dat
  unset %piratesirc-sounds.*
  echo -a 🕱🎵 PiratesIRC Sounds Uninstalled 😥
}
on 1:START:/.PiratesIRC-Sounds.VesionCheck
alias PiratesIRC-Sounds.setup {
  ;/PiratesIRC-Sounds.setup - asks for input to setup the script
  if ($dialog(pircs.md)) dialog -x pircs.md
  if (!$exists(PiratesIRC-sounds.log)) write -c PiratesIRC-sounds.log
  set %piratesirc-sounds.network $input(IRC Network PiratesIRC is on. $+ $crlf $+ Enter * for all networks.,qe,PiratesIRC-Sounds Network,$network)
  if (!%piratesirc-sounds.network) { noop $input(Setup Cancelled!,wo,PiratesIRC-Sounds) | return }
  set %piratesirc-sounds.channel $input(Enter the Channel PiratesIRC is located on:,e,PiratesIRC-Sounds,#pirates)
  if (!%piratesirc-sounds.channel) { noop $input(Setup Cancelled!,wo,PiratesIRC-Sounds) | return }
  set %piratesirc-sounds.bot $input(Enter the PiratesIRC bot's nickname:,e,PiratesIRC-Sounds,CaptainJack)
  if (!%piratesirc-sounds.bot) { noop $input(Setup Cancelled!!,wo,PiratesIRC-Sounds) | return }
  set %piratesirc-sounds.directory $sdir($sound(mp3),Location of PiratesIRC Sounds)
  if (!%piratesirc-sounds.directory) { noop $input(Setup Cancelled!!,wo,PiratesIRC-Sounds) | return }
  if ($input(Attempt to download missing files when triggered?,qy,PiratesIRC-Sounds)) set %piratesirc-sounds.download $ifmatch
  if ($input(Mute on away?,qy,PiratesIRC-Sounds)) set %piratesirc-sounds.muteonaway $ifmatch
  if ($input(Mute on Do Not Disturb?,qy,PiratesIRC-Sounds)) set %piratesirc-sounds.muteonDnD $ifmatch
  var %a $input(Enable Pirates-IRC Sounds?,qy,PiratesIRC-Sounds)
  .PiratesIRC-Sounds.enabled.toggle %a
  inc %piratesirc-sounds.setup 1
  unset %piratesirc-sounds.*.sounds.DISABLED
  unset %piratesirc-sounds.file.disabled.*
  echo -a 
  echo -a 🕱🎵 PiratesIRC Sounds settings 🕱🎵
  echo -a $tab Status: $iif(%piratesirc-sounds.enabled,3Enabled,4Disabled) - Channel: $iif(%piratesirc-sounds.channel, $+ $ifmatch,4none) - Bot Nickname: $iif(%piratesirc-sounds.bot, $+ $ifmatch,4none) - Directory: $iif(%piratesirc-sounds.directory, $+ $ifmatch,4none)
  echo -a $tab Download missing files: $iif(%piratesirc-sounds.download,3Enabled,4Disabled) -  Mute on Away: $iif(%piratesirc-sounds.muteonaway,3Enabled,4Disabled) - Mute on Do Not Disturb: $iif(%piratesirc-sounds.muteonDnD,3Enabled,4Disabled)
  echo -a 
  PiratesIRC-Sounds.WriteLog Full setup complete: Enabled? %piratesirc-sounds.enabled - %piratesirc-sounds.bot on %piratesirc-sounds.channel - %n files in %piratesirc-sounds.directory - download? %piratesirc-sounds.download - away mute? %piratesirc-sounds.muteonaway - DND mute? %piratesirc-sounds.muteonDnD
  .PiratesIRC-Sound.ExtractZip
  var %n $findfile(%piratesirc-sounds.directory,*.mp3,0,1)
  if (%n <= 45) echo -a Sound files are missing! Download the sound pack at 12https://piratesirc.com/sounds/sounds.zip and extract to $iif(%piratesirc-sounds.directory, $+ %piratesirc-sounds.directory,the sounds directory specified in /PiratesIRC-Sounds.setup)
  else echo -a %n sounds found in %piratesirc-sounds.directory $+ ! You can perform a sound test in %piratesirc-sounds.channel with !Pirates Sound Test
  PiratesIRC-Sounds.VesionCheck
  PiratesIRC-Sounds.Dialog.Open
}
alias PiratesIRC-Sounds.enabled.toggle {
  ;/PiratesIRC-Sounds.enabled.toggle - enables/disables sounds
  if (!$1) {
    set %piratesirc-sounds.enabled 0 
    .disable #PiratesIRC-Sounds
    if ($show) echo -a 🕱🎵 PiratesIRC Sounds - 4Disabled
  }
  else {
    var %error
    if (!%piratesirc-sounds.channel) set %error Channel is not set!
    if (!%piratesirc-sounds.bot) set %error Bot's Nickname is not set!
    if (!%piratesirc-sounds.directory) set %error Sounds Directory is not set!
    if (%error) echo -a 4PiratesIRC-Sounds Error: %error Run Setup! /PiratesIRC-Sounds.setup
    else {
      set %piratesirc-sounds.enabled 1
      .enable #PiratesIRC-Sounds
      if ($show) echo -a 🕱🎵 PiratesIRC Sounds - 3Enabled
    }
  }
}
alias PiratesIRC-Sound.ExtractZip {
  ;/PiratesIRC-Sound.ExtractZip - if sounds.zip exists in sound dir, extracts + overwrites
  var %r, %file %piratesirc-sounds.directory $+ sounds.zip
  if ($exists(%file)) set %r $zip(%file,eo,%piratesirc-sounds.directory)
  if ($show) && (%r) {
    var %n $findfile(%piratesirc-sounds.directory,*.mp3,0)
    var %msg %n sound files have been extracted and ready for use!
    if ($dialog(pircs.md)) {
      did -ra pircs.md 4 %msg
      PiratesIRC-Sounds.Dialog.PopulateSounds
    }
    else echo -a 🕱🎵 PiratesIRC Sounds - %msg
  }
  else {
    var %msg Unable to extract Sounds.zip! Download from https://piratesirc.com/sounds/sounds.zip
    if ($dialog(pircs.md)) {
      did -b pircs.md 328
      did -e pircs.md 327
      did -ra pircs.md 4 %msg
    }
    else echo -a %msg
  }
  .timer 1 1 .remove -b %file
}
alias PiratesIRC-Sounds.DownloadFile {
  ;/PiratesIRC-Sounds.DownloadFile <file> - attempts to download any missing sound files
  if (%piratesirc-sounds.download.failed.cooldown) || (!%piratesirc-sounds.download) || (!$1) return
  var %file $nopath($1-) $+ .mp3
  if ($exists(" $+ %piratesirc-sounds.directory $+ %file $+ .mp3 $+ ")) return
  var %url https://piratesirc.com/sounds/ $+ %file
  if (%url isnum) { 
    if ($urlget(%url).state == fail) {
      var %e Unable to download %file!
      if (%piratesirc-sounds.debug) echo 4 -at PiratesIRC-Sounds Download Error: %e
      PiratesIRC-Sounds.WriteLog %e
      set -u3600 %piratesirc-sounds.download.failed.cooldown %e
      return
    }
  }
  else {
    var %a $urlget(%url,gfi,%piratesirc-sounds.directory,PiratesIRC-Sounds.FileDownloaded $gettok(%file,1,32))
    if (!%a) {
      var %e Unable to download %file Code: %a
      PiratesIRC-Sounds.WriteLog %e
      if (%piratesirc-sounds.debug) echo 4 -at PiratesIRC-Sounds Download Error: %e
      set -u3600 %piratesirc-sounds.download.failed.cooldown %e
    }
  }
}
alias PiratesIRC-Sounds.FileDownloaded {
  ;/PiratesIRC-Sounds.FileDownloaded <file> - download was successful
  if ($1) {
    PiratesIRC-Sounds.WriteLog Downloaded $1
    PiratesIRC-Sounds.PlaySound download $1
    inc %piratesirc-sounds.stats.downloads
  }
}
alias PiratesIRC-Sounds.WriteLog {
  if (%piratesirc-sounds.DisableLog) return
  var %t ( $+ $date $time $+ )
  write -il1 PiratesIRC-sounds.log %t $1-
  if ($dialog(pircs.md)) did -i pircs.md 431 1 %t $1-
  if ($lines(PiratesIRC-sounds.log) > 100) write -d PiratesIRC-sounds.log
}
alias PiratesIRC-Sounds.VesionCheck {
  ;/PiratesIRC-Sounds.VesionCheck - checks for new version of script
  if (%piratesirc-sounds.versioncheck.cooldown) return
  if ($show) WebsiteDataTester $PiratesIRC-Sounds.website
  else .WebsiteDataTester $PiratesIRC-Sounds.website
  set -u7200 %piratesirc-sounds.versioncheck.cooldown 1
}

;https://forums.mirc.com/ubbthreads.php/topics/269401/re-youtube-link-to-title-for-mirc#Post269401
alias -l WebsiteDataTester { noop $urlget($1-,gb,& $+ $ticks,$iif($show,ScrapeWebsiteData,.ScrapeWebsiteData)) }
alias -l ScrapeWebsiteData { 
  var %b = $urlget($1).target
  if ($bfind(%b,1,/<title>(.*)<\/title>/i,Title).regex) { var %title = $regml(Title,1) }

  ;modified for PiratesIRC Sound Script
  var %msg
  var %remote.ver $remove($wildtok(%title,v*,1,32),v)
  if (%remote.ver > $PiratesIRC-Sound.version) {
    echo -a A new version of the PiratesIRC-Sound Script $paren(%remote.ver) is available at $PiratesIRC-Sounds.website
    if ($dialog(pircs.md)) did -ra pircs.md 4 New version $paren(%remote.ver) available!
    PiratesIRC-Sounds.WriteLog New version available: %remote.ver Local version is $PiratesIRC-Sound.version
    .timer 1 3 url $PiratesIRC-Sounds.website
  }
  else {
    set %msg You have the latest version of PiratesIRC Sound Script $paren($PiratesIRC-Sound.version)
    if ($show) echo -a %msg
    if ($dialog(pircs.md)) did -ra pircs.md 4 %msg
    PiratesIRC-Sounds.WriteLog Version check - no updates
  }
}

alias PiratesIRC-Sounds.filtersoundfile {
  ;$PiratesIRC-Sounds.filtersoundfile(text) - returns the sound
  var %t $strip($1-)
  var %file $remove($gettok(%t,$calc($numtok(%t,55356) - 1),55356),�,🎵)
  if ($regsub(removeinvalids,%file,[^a-zA-Z0-9]+,,%file)) return %file
}
alias PiratesIRC-Sounds.PlaySound {
  ;/PiratesIRC-Sounds.PlaySound <method/source> <file name> - plays sound
  if (!%piratesirc-sounds.enabled) return
  if (%piratesirc-sounds.muteonDnD) && ($donotdisturb) return
  if (%piratesirc-sounds.muteonaway) && ($away) return
  if (!$2) return
  var %source $1
  var %file $remove($2,.mp3)
  if (%source == download) set %file $remove($2,.mp3)
  if (%file) {
    var %f $nopath(%file)
    if (%source == Channel) && (%piratesirc-sounds.channel.sounds.DISABLED) { PiratesIRC-Sounds.WriteLog %source sounds have been DISABLED - %f triggered by $nick | return }
    if (%source == Private) && (%piratesirc-sounds.private.sounds.DISABLED) { PiratesIRC-Sounds.WriteLog %source sounds have been DISABLED - %f triggered by $nick | return }
    if ($eval($+(%,piratesirc-sounds.file.disabled.,%f),2)) { PiratesIRC-Sounds.WriteLog %f has been DISABLED - triggered by $nick / %source | return }

    set %file " $+ %piratesirc-sounds.directory $+ %file $+ .mp3 $+ "
    if ($exists(%file)) {
      if (%piratesirc-sounds.debug) echo -st play file: %file
      PiratesIRC-Sounds.WriteLog $nick %source triggered sound: %f
      if ($dialog(pircs.md)) did -ra pircs.md 4 Playing: $remove($nopath(%f),.mp3)
      .splay -p %file
      inc %piratesirc-sounds.stats.played
    }
    else {
      set %file $remove($nopath(%file),.mp3)
      if (%piratesirc-sounds.debug) echo -st %file does not exist!
      if (%piratesirc-sounds.download) PiratesIRC-Sounds.DownloadFile %file
      PiratesIRC-Sounds.WriteLog %file does not exist! $iif(%piratesirc-sounds.download,Attempting to download...)
    }
  }
}

#PiratesIRC-Sounds on
on 1:TEXT:*🎵*:%piratesirc-sounds.channel:{
  ;channel messages
  if ($chr(37) isin $1-) || ($chr(36) isin $1-) return
  if (%piratesirc-sounds.bot !iswm $nick) return
  if (%piratesirc-sounds.network) && (%piratesirc-sounds.network !iswm $network) return
  if (!%piratesirc-sounds.enabled) || (!%piratesirc-sounds.channel) || (!%piratesirc-sounds.bot) || (!%piratesirc-sounds.directory) return
  if ($PiratesIRC-Sounds.filtersoundfile($1-)) { PiratesIRC-Sounds.PlaySound Channel $ifmatch | inc %piratesirc-sounds.stats.channelsounds }
}
on 1:TEXT:*🎵*:?:{
  ;private messages
  if (%piratesirc-sounds.bot != $nick) return
  if ($chr(37) isin $1-) || ($chr(36) isin $1-) return
  if (%piratesirc-sounds.bot !iswm %piratesirc-sounds.bot) return
  if (%piratesirc-sounds.network) && (%piratesirc-sounds.network !iswm $network) return
  if (!%piratesirc-sounds.enabled) || (!%piratesirc-sounds.bot) || (!%piratesirc-sounds.directory) return
  if ($PiratesIRC-Sounds.filtersoundfile($1-)) { PiratesIRC-Sounds.PlaySound Private $ifmatch | inc %piratesirc-sounds.stats.privatesounds }
}
on 1:NOTICE:*🎵*:?:{
  ;private notices
  if (%piratesirc-sounds.bot != $nick) return
  if ($chr(37) isin $1-) || ($chr(36) isin $1-) return
  if (%piratesirc-sounds.bot !iswm $nick) return
  if (%piratesirc-sounds.network) && (%piratesirc-sounds.network !iswm $network) return
  if (!%piratesirc-sounds.enabled) || (!%piratesirc-sounds.bot) || (!%piratesirc-sounds.directory) return
  if ($PiratesIRC-Sounds.filtersoundfile($1-)) { PiratesIRC-Sounds.PlaySound Private $ifmatch | inc %piratesirc-sounds.stats.privatesounds }
}
#PiratesIRC-Sounds end

menu menubar,status,channel,nicklist {
  ;Access the menu via IRC Client's Command's menu
  PiratesIRC Sounds
  .Dialog:/PiratesIRC-Sounds.Dialog.Open
  .-
  .Status - $iif(%piratesirc-sounds.enabled,Enabled,Disabled):/PiratesIRC-Sounds.enabled.toggle $iif(%piratesirc-sounds.enabled,0,1)
  .-
  ..Settings
  ..Run Full Setup:/PiratesIRC-sounds.setup
  ..-
  ..Network - %piratesirc-sounds.network : { $iif($network && $input(Set Network to $network $+ ?,wy,PiratesIRC-Sounds),set % $+ piratesirc-sounds.network $network,noop) }
  ..Channel - %piratesirc-sounds.channel : { $iif($chan && $input(Set Channel to $chan $+ ?,wy,PiratesIRC-Sounds),set % $+ piratesirc-sounds.channel $chan,noop) }
  ..Bot Nickname - %piratesirc-sounds.bot : { $iif($1 && $input(Set Bot to $1 $+ ?,wy,PiratesIRC-Sounds),set % $+ piratesirc-sounds.bot $1,noop) }
  ..-
  ..$iif(!%piratesirc-sounds.versioncheck.cooldown,Check for new version):/PiratesIRC-Sounds.VesionCheck
  .-
  .$iif($insong,Stop Current Sound - $remove($nopath($insong.fname),.mp3)):/splay stop
  .-
  .-
  .View Log:/run PiratesIRC-sounds.log
}
alias PiratesIRC-Sounds.Dialog.Open {
  var %dlg pircs.md
  if ($dialog(%dlg)) dialog -e %dlg
  else {
    inc %piratesirc-sounds.stats.dialog
    dialog -mad %dlg %dlg
  }
}
dialog pircs.md {
  title ""
  size -1 -1 278 125
  option dbu
  tab "Main", 100, 3 3 271 102
  button "Check for new version", 101, 8 89 90 12, tab 100
  check "Enabled", 102, 8 24 50 10, tab 100
  button "Uninstall", 103, 204 89 64 12, tab 100
  edit "", 105, 6 35 262 50, tab 100 read multi return autovs vsbar
  button "Run Full Setup", 106, 202 21 65 12, tab 100
  button "Stop Current Sound", 107, 106 89 90 12, hide tab 100
  tab "Settings", 200
  combo 205, 50 23 60 86, tab 200 sort size edit drop
  text "Network:", 206, 8 24 40 8, tab 200
  text "Channel:", 207, 8 36 40 8, tab 200
  text "Bot Name:", 208, 8 45 40 8, tab 200
  check "Auto-download missing files", 209, 8 56 100 10, tab 200
  check "Mute on /away", 210, 8 67 100 10, tab 200
  text "Sounds Directory:", 211, 8 93 58 8, tab 200
  button "None", 212, 68 91 200 12, tab 200
  edit "", 213, 50 35 60 10, tab 200 center
  check "Mute on /dnd (Do Not Disturb)", 215, 8 78 120 10, tab 200
  edit "", 214, 50 45 60 10, tab 200 center
  box "Play Sounds Received by:", 216, 158 24 110 44, tab 200
  check "Channel", 217, 166 36 96 10, tab 200
  check "Private Msg/Notice", 218, 166 50 96 10, tab 200
  tab "Sounds", 300
  button "Download Sounds Archive", 327, 176 72 94 12, tab 300
  button "Extract Sounds Archive", 328, 176 88 94 12, tab 300
  button "Open Sounds Directory", 305, 176 22 94 12, disable tab 300
  list 302, 8 30 68 70, tab 300 sort size vsbar
  list 307, 99 31 68 70, tab 300 size
  text "Enabled Sounds", 301, 8 22 68 8, tab 300 center
  text "Disabled Sounds", 306, 99 22 68 8, tab 300 center
  button ">", 303, 80 46 16 12, tab 300
  button "<", 304, 80 66 16 12, tab 300
  tab "Log", 400
  check "Enable Log", 430, 8 24 50 10, tab 400
  edit "", 431, 4 35 267 68, tab 400 read multi vsbar
  button "Clear", 432, 232 22 37 12, tab 400
  button "OK", 1, 236 110 37 12, default ok
  link "PiratesIRC.com", 2, 4 112 60 8
  button "?", 3, 224 110 10 12, hide
  text "", 4, 65 112 156 8, center
}

on 1:dialog:pircs.md:init:0:{
  if (%piratesirc-sounds.network) && (%piratesirc-sounds.channel) && (%piratesirc-sounds.bot) set %piratesirc-sounds.setup 1
  if (%piratesirc-sounds.enabled) did -c $dname 102
  dialog -t $dname PiratesIRC Sounds v $+ $PiratesIRC-Sound.version
  if (%piratesirc-sounds.versioncheck.cooldown) did -b $dname 101
  var %f piratesirc-sounds.dat 
  write -c %f 
  write %f 🕱 🎵 Welcome to the PiratesIRC Sounds Script v $+ $PiratesIRC-Sound.version $+ ! 🎵 🕱 $crlf  ​
  write %f Settings tab - Settings for Network, Channel, and Playing Sounds $crlf $+ Sounds tab - Download, Extract, and enabled/disable individual sounds $crlf $+ Log tab - View list of recent events $crlf  ​
  write %f Test by typing !P Sound Test on $iif(%piratesirc-sounds.channel,$upper(%piratesirc-sounds.channel),the game channel) $crlf $+ - - - If having issues, Run Full Setup - - - $crlf  ​
  write %f Stats:
  write %f Sounds played: $iif(%piratesirc-sounds.stats.played,%piratesirc-sounds.stats.played,0)
  write %f Sounds played via Channel: $iif(%piratesirc-sounds.stats.channelsounds,%piratesirc-sounds.stats.channelsounds,0)
  write %f Sounds played via Private: $iif(%piratesirc-sounds.stats.privatesounds,%piratesirc-sounds.stats.privatesounds,0)
  write %f Sounds downloaded: $iif(%piratesirc-sounds.stats.downloads,%piratesirc-sounds.stats.downloads,0)
  write %f This dialog has been opened %piratesirc-sounds.stats.dialog times!
  loadbuf -o $dname 105 %f

  ;tab 200 Settings
  ;populate networks
  if (%piratesirc-sounds.network != *) did -a $dname 205 *
  var %t $scon(0)
  if (!%t) {
    did -a $dname 205 %piratesirc-sounds.network
    did -c $dname 205 1
  }
  else {
    var %n, %a *
    var %i 0
    while (%t > %i) {
      inc %i
      set %n $scon(%i).network
      if (%n == %piratesirc-sounds.network) continue
      set %a $addtok(%a,%n,44)
      if (%n) did -a $dname 205 %n
    }
    if (%piratesirc-sounds.network) {
      if (!$findtok(%a,%piratesirc-sounds.network,0,44)) did -a $dname 205 %piratesirc-sounds.network
      elseif (%piratesirc-sounds.network != $did(205).seltext) did -a $dname 205 %piratesirc-sounds.network
    }
    if (%piratesirc-sounds.network) {
      var %i 0
      while ($did(205).lines > %i) {
        inc %i
        did -c $dname 205 %i
        if (%piratesirc-sounds.network) && ($did(205).seltext == %piratesirc-sounds.network) break
      }
    }
  }
  did -ra $dname 213 %piratesirc-sounds.channel
  did -ra $dname 214 %piratesirc-sounds.bot
  if (%piratesirc-sounds.download) did -c $dname 209
  if (%piratesirc-sounds.muteonaway) did -c $dname 210
  if (%piratesirc-sounds.muteonDnD) did -c $dname 215
  did -c $dname 217,218
  if (%piratesirc-sounds.channel.sounds.DISABLED) did -u $dname 217
  if (%piratesirc-sounds.privatesounds.sounds.DISABLED) did -u $dname 218
  did -ra $dname 212 $iif(%piratesirc-sounds.directory,$ifmatch,None)
  ;tab 300 Sounds
  unset %piratesirc-sounds.temp.dlgtab300
  if (%piratesirc-sounds.directory) did -e $dname 305
  if ($findfile(%piratesirc-sounds.directory,sounds.zip,0)) {
    did -e $dname 328
    did -b $dname 327
    .timer 1 0 did -ra $dname 4 Sounds.zip found! Extract using the button in the Sounds tab...
  }
  else {
    var %n $calc($did(302).lines + $did(307).lines)
    if (%n >= $PiratesIRC-Sound.NumberofFilesinZip) did -b $dname 327
    else did -e $dname 327
    did -b $dname 328
  }
  ;tab 400 Log
  if (!%piratesirc-sounds.DisableLog) did -c $dname 430
  did -r $dname 431
  if ($exists(PiratesIRC-sounds.log)) loadbuf -pio $dname 431 PiratesIRC-sounds.log

  if ($insong) {
    did -ra $dname 4 Playing: $remove($nopath($insong.fname),.mp3)
    did -v $dname 107
  }
  else {
    var %n $findfile(%piratesirc-sounds.directory,*.mp3,0,1)
    if (%n) did -ra $dname 4 %n sound files found and ready for use!
    else did -ra $dname 4 No sounds found! Download via the Sounds tab, Download Archive
  }
  if (!%piratesirc-sounds.setup) {
    .timer 1 1 did -ra $dname 4 Setup has not been completed! Click 'Run Full Setup'
    did -f $dname 106
  }
}
on 1:dialog:pircs.md:Sclick:2:url http://www.piratesirc.com
on 1:dialog:pircs.md:Sclick:3:did -ra $dname 4 Right click on any option for a description
on 1:dialog:pircs.md:Sclick:101:{
  did -ra $dname 4 Checking for new version...
  .PiratesIRC-Sounds.VesionCheck
  did -b $dname 101
}
on 1:dialog:pircs.md:Sclick:102:{
  set %piratesirc-sounds.enabled $iif($did(102).state,1,0)
  did -ra $dname 4 PiratesIRC Sounds: $iif(%piratesirc-sounds.enabled,Enabled 🥳,Disabled ☹)
}
on 1:dialog:pircs.md:Sclick:103:{
  dialog -i $dname
  var %a $input(Are you sure you want to uninstall PiratesIRC Sounds?,wybg,Uninstall)
  if (%a) .timer 1 0 unload -rs $script
  else dialog -e $dname
}
on 1:dialog:pircs.md:Sclick:106:{
  dialog -i $dname
  var %a $input(Are you sure you want to re-run the Setup? $crlf $+ This will reset all options but may correct issues from sounds playing.,qybg,Run Full Setup?)
  if (%a) { dialog -x $dname | PiratesIRC-Sounds.setup }
  else dialog -e $dname
}
on 1:dialog:pircs.md:Sclick:107:{
  var %f $remove($nopath($insong.fname),.mp3)
  splay stop
  did -ra $dname 4 Stopped sound: %f
  did -h $dname 107
}
on 1:dialog:pircs.md:edit:205:if ($did(205)) { set %piratesirc-sounds.network $ifmatch | did -ra $dname 4 Network set to $ifmatch }
on 1:dialog:pircs.md:Sclick:205:if ($did(205).seltext) { set %piratesirc-sounds.network $ifmatch | did -ra $dname 4 Network set to $ifmatch }
on 1:dialog:pircs.md:Sclick:209:{
  set %piratesirc-sounds.download $iif($did(209).state,1,0)
  did -ra $dname 4 Missing files will $iif(%piratesirc-sounds.download,be download,NOT be downloaded) when triggered
}
on 1:dialog:pircs.md:Sclick:210:{
  set %piratesirc-sounds.muteonaway $iif($did(210).state,1,0)
  did -ra $dname 4 All sounds will $iif(%piratesirc-sounds.muteonaway,be MUTED,PLAY) when you are /AWAY
}
on 1:dialog:pircs.md:edit:214:{
  if ($did(214)) {
    set %piratesirc-sounds.bot $ifmatch
    did -ra $dname 4 Bot nickname set to $ifmatch
  }
}
on 1:dialog:pircs.md:Sclick:215:{
  set %piratesirc-sounds.muteonDnD $iif($did(215).state,1,0)
  did -ra $dname 4 All sounds will $iif(%piratesirc-sounds.muteonDnD,be MUTED,PLAY) when you /DnD
}
on 1:dialog:pircs.md:Sclick:212:{
  var %dir $iif(%piratesirc-sounds.directory,$ifmatch,$mircdir)
  set %dir $sdir(%dir,Location of PiratesIRC Sounds)
  if (%dir) {
    set %piratesirc-sounds.directory %dir
    did -ra $dname 212 %dir
    var %n $findfile(%dir,*.mp3,0)
    if (%n) did -ra $dname 4 %n sounds files found!
    else did -ra $dname 4 No files found! Did you select the correct directory?
  }
  else did -ra $dname 4 $iif(%piratesirc-sounds.directory,Sound directory remains $ifmatch,No sound directory selected!)
  unset %piratesirc-sounds.temp.dlgtab300
}
on 1:dialog:pircs.md:Sclick:217:{
  set %piratesirc-sounds.channel.sounds.DISABLED $iif($did(217).state,0,1)
  did -ra $dname 4 Sounds triggered in $iif(%piratesirc-sounds.channel,$upper(%piratesirc-sounds.channel),the game channel) will $iif(%piratesirc-sounds.channel.sounds.DISABLED,INGORED,be PLAYED)
}
on 1:dialog:pircs.md:Sclick:218:{
  set %piratesirc-sounds.privatesounds.sounds.DISABLED $iif($did(218).state,0,1)
  did -ra $dname 4 Sounds triggered via Private Messages/Notices will $iif(%piratesirc-sounds.private.sounds.DISABLED,INGORED,be PLAYED)
}
on 1:dialog:pircs.md:Sclick:300:{
  var %n $var(%piratesirc-sounds.file.disabled.*,0)
  if (%n) did -ra $dname 4 %n $iif(%n == 1,sound has,sounds have) been disabled.
  if (!%piratesirc-sounds.temp.dlgtab300) { PiratesIRC-Sounds.Dialog.PopulateSounds | set %piratesirc-sounds.temp.dlgtab300 1 }
}
on 1:dialog:pircs.md:Sclick:302:{
  did -e $dname 303
  did -b $dname 304
  did -u $dname 307
}
on 1:dialog:pircs.md:Sclick:303:{
  if ($did(302).seltext) {
    set %piratesirc-sounds.file.disabled. $+ $ifmatch 1
    did -a $dname 307 $ifmatch
    did -d $dname 302 $did(302).sel
    did -ra $dname 4 Sound ' $+ $upper($ifmatch) $+ ' will no longer be played
  }
  did -b $dname 303
}
on 1:dialog:pircs.md:Sclick:307:{
  did -e $dname 304
  did -b $dname 303
  did -u $dname 302
}
on 1:dialog:pircs.md:Sclick:304:{
  if ($did(307).seltext) {
    unset %piratesirc-sounds.file.disabled. $+ $ifmatch
    did -a $dname 302 $ifmatch
    did -d $dname 307 $did(307).sel
    did -ra $dname 4 Sound ' $+ $upper($ifmatch) $+ ' will be played when triggered
  }
  did -b $dname 304
}
on 1:dialog:pircs.md:Sclick:305:run %piratesirc-sounds.directory
on 1:dialog:pircs.md:Sclick:327:{
  did -ra $dname 4 Opening browser and downloading sounds.zip
  url https://piratesirc.com/sounds/sounds.zip
  var %msg Move sounds.zip to %piratesirc-sounds.directory and Extract
  echo -a Move sounds.zip to %piratesirc-sounds.directory and Extract
  .timer 1 2 did -ra $dname 4 %msg
  .timerPiratesIRC-Sounds.Check.SoundsZip -o 0 3 PiratesIRC-Sounds.Dialog.Timer.Check.SoundsZip
}
on 1:dialog:pircs.md:Sclick:328:{
  did -ra $dname 4 Extracting Sounds.zip...
  PiratesIRC-Sound.ExtractZip
  did -b $dname 328
  unset %piratesirc-sounds.temp.dlgtab300
}
on 1:dialog:pircs.md:Sclick:430:{
  set %piratesirc-sounds.DisableLog $iif($did(430).state,0,1)
  did -ra $dname 4 Logging is $iif(%piratesirc-sounds.DisableLog,Disabled,Enabled)
}
on 1:dialog:pircs.md:Sclick:432:{
  did -r $dname 431
  write -c PiratesIRC-sounds.log
  did -ra $dname 4 Cleared log
}
on 1:dialog:pircs.md:Rclick:2:did -ra $dname 4 Opens website in your default browser
on 1:dialog:pircs.md:Rclick:102:did -r $dname 4 $iif($rand(1,2) == 1,Beep,Boop)
on 1:dialog:pircs.md:close:{
  set %piratesirc-sounds.bot $did(214)
  set %piratesirc-sounds.channel $did(213)
  .timerPiratesIRC-Sounds.Check.SoundsZip off
  unset %piratesirc-sounds.temp.dlgtab300
}
alias PiratesIRC-Sounds.Dialog.Timer.Check.SoundsZip {
  var %dlg pircs.md
  if (!$dialog(%dlg)) .timerPiratesIRC-Sounds.Check.SoundsZip off
  if ($exists(%piratesirc-sounds.directory $+ sounds.zip)) {
    did -e %dlg 328
    did -b %dlg 327
    var %msg Sounds.zip found! Extract using the button in the Sounds tab...
    echo -a %msg
    did -ra %dlg 4 %msg
    .timerPiratesIRC-Sounds.Check.SoundsZip off
  }
}
alias PiratesIRC-Sounds.Dialog.PopulateSounds {
  var %dlg pircs.md
  if (!$dialog(%dlg)) return
  var %n $findfile(%piratesirc-sounds.directory,*.mp3,0)
  if (%n >= $PiratesIRC-Sound.NumberofFilesinZip) did -b %dlg 327
  if (%n) {
    var %f, %i 0
    while (%n > %i) {
      inc %i
      set %f $remove($nopath($findfile(%piratesirc-sounds.directory,*.mp3,%i)),.mp3)
      if (!$eval(% $+ piratesirc-sounds.file.disabled. $+ %f,2)) did -a %dlg 302 %f
    }

    set %n $var(%piratesirc-sounds.file.disabled.*,0)
    set %i 0
    while (%n > %i) {
      inc %i
      did -a %dlg 307 $gettok($var(%piratesirc-sounds.file.disabled.*,%i),4-,46)
    }
  }
}
;-------------------------------- END OF CODE --------------------------------

My Pastes
Pirates-IRC Sound Script v0.30
mIRC | 38 days ago | 27.37 KB
PiratesIRC 2021 Changelog
362 days ago | 21.45 KB
PiratesIRC Crossword Wordlist
1 year ago | 1.43 KB
!Jizz (NSFW)
1 year ago | 8.17 KB
Rep script (!Love/!Hate)
1 year ago | 19.34 KB
PiratesIRC 2020 Changelog
1 year ago | 30.42 KB
PiratesIRC 2019 Changelog
1 year ago | 32.22 KB
PiratesIRC 2018 Changelog
1 year ago | 33.04 KB
Public Pastes
Untitled
C# | 16 min ago | 1.20 KB
kkk
Lua | 18 min ago | 0.11 KB
Untitled
JavaScript | 35 min ago | 1.81 KB
CC Websocket test
Lua | 45 min ago | 0.28 KB
Paste Ping
C | 1 hour ago | 0.02 KB
aa
Lua | 1 hour ago | 0.48 KB
Untitled
Python | 2 hours ago | 3.37 KB
graf
HTML 5 | 2 hours ago | 4.99 KB
create new paste  /  syntax languages  /  archive  /  faq  /  tools  /  night mode  /  api  /  scraping api  /  news  /  pro
privacy statement  /  cookies policy  /  terms of serviceupdated  /  security disclosure  /  dmca  /  report abuse  /  contact

By using Pastebin.com you agree to our cookies policy to enhance your experience.
Site design & logo © 2022 Pastebin

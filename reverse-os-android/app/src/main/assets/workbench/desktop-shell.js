'use strict';
// The APK hosts the PC desktop. Window focus never changes the layout mode.
window.ReverseShell={
  mode:'desktop',
  back(){
    if($('#input-dialog').open){resolveDialog(null);return true;}
    if(!$('#context-menu').hidden){hideContext();return true;}
    if(!$('#launcher').hidden){hideLauncher();return true;}
    return false;
  }
};

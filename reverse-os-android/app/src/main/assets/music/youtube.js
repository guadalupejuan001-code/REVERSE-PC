/* Runs only in the unprivileged YouTube WebView. Never exposes a native bridge. */
(() => {
  'use strict';
  if (window.__reverseMusic) return;
  let shield = false, timer = null, observer = null, altered = null;
  const video = () => document.querySelector('video');
  const adShowing = () => !!document.querySelector('.ad-showing,.ad-interrupting');
  const selectors = 'ytd-ad-slot-renderer,ytm-ad-slot-renderer,ytd-display-ad-renderer,ytd-promoted-sparkles-web-renderer,ytm-promoted-sparkles-web-renderer,ytmusic-mealbar-promo-renderer,.ytp-ad-overlay-container,#player-ads';
  function restore() {
    if (!altered) return;
    altered.video.muted = altered.muted;
    altered = null;
  }
  function filter() {
    if (!shield) return;
    // Act only when the player explicitly identifies advertising. Never seek a song.
    const v = video();
    if (!adShowing() || !v) { restore(); return; }
    if (altered?.video !== v) { restore(); altered = {video:v, muted:v.muted}; }
    v.muted = true;
    const skip = document.querySelector('.ytp-ad-skip-button,.ytp-ad-skip-button-modern,.ytp-skip-ad-button,button.ytp-ad-skip-button');
    if (skip && !skip.disabled && skip.getClientRects().length) skip.click();
    if (Number.isFinite(v.duration) && v.duration > 0 && v.duration < 600
        && v.currentTime < v.duration - .1) {
      try { v.currentTime = v.duration; } catch (_) {}
    }
  }
  function setShield(enabled) {
    shield = !!enabled;
    clearInterval(timer); timer = null;
    observer?.disconnect(); observer = null;
    document.getElementById('reverse-music-filter')?.remove();
    if (!shield) { restore(); return; }
    const style = document.createElement('style'); style.id = 'reverse-music-filter';
    style.textContent = selectors + '{display:none!important}';
    (document.head || document.documentElement).append(style);
    observer = new MutationObserver(filter);
    observer.observe(document.documentElement, {subtree:true, childList:true, attributes:true, attributeFilter:['class']});
    timer = setInterval(filter, 600); filter();
  }
  async function command(action, value) {
    const v = video();
    if (action === 'play' || (action === 'toggle' && v?.paused)) {
      if (!v) return false;
      try { await v.play(); return true; } catch (_) { return false; }
    }
    if (action === 'pause' || action === 'toggle') { v?.pause(); return !!v; }
    if (action === 'seek') {
      if (!v || adShowing() || !Number.isFinite(v.duration) || !Number.isFinite(value)) return false;
      v.currentTime = Math.max(0, Math.min(v.duration, value)); return true;
    }
    const selector = action === 'next'
      ? '.ytp-next-button,ytmusic-player-bar .next-button'
      : action === 'previous' ? '.ytp-prev-button,ytmusic-player-bar .previous-button' : '';
    const button = selector && document.querySelector(selector);
    if (button && button.getClientRects().length && button.getAttribute('aria-disabled') !== 'true') { button.click(); return true; }
    return false;
  }
  function snapshot() {
    const v = video();
    const title = document.querySelector('ytmusic-player-bar .title,ytm-slim-video-metadata-section-renderer h1,h1.ytd-watch-metadata,h1.title')?.textContent?.trim()
      || document.title.replace(/ - YouTube(?: Music)?$/, '');
    return {url:location.href.slice(0,4096),title:(title || 'YouTube').slice(0,240),
      hasMedia:!!v,paused:v ? v.paused : true,ad:adShowing(),
      time:v && Number.isFinite(v.currentTime) ? v.currentTime : 0,
      duration:v && Number.isFinite(v.duration) ? v.duration : 0};
  }
  window.__reverseMusic = {setShield, command, snapshot};
})();

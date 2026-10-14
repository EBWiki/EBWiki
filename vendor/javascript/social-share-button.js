window.SocialShareButton = {
  openUrl(url, width = 640, height = 480) {
    const left = (screen.width / 2) - (width / 2)
    const top = (screen.height * 0.3) - (height / 2)
    const opt = `width=${width},height=${height},left=${left},top=${top},menubar=no,status=no,location=no`
    window.open(url, 'popup', opt)
    return false
  },

  share(el) {
    if (el.getAttribute == null) {
      el = document.querySelector(el)
    }

    const site = el.getAttribute('data-site')
    const appkey = el.getAttribute('data-appkey') || ''
    const $parent = el.parentNode
    const title = encodeURIComponent(el.getAttribute(`data-${site}-title`) || $parent.getAttribute('data-title') || '')
    const img = encodeURIComponent($parent.getAttribute('data-img') || '')
    let url = encodeURIComponent($parent.getAttribute('data-url') || '')
    const via = encodeURIComponent($parent.getAttribute('data-via') || '')
    const desc = encodeURIComponent($parent.getAttribute('data-desc') || ' ')

    const ga = window[window.GoogleAnalyticsObject || 'ga']
    if (typeof ga === 'function') {
      ga('send', 'event', 'Social Share Button', 'click', site)
    }

    if (url.length === 0) {
      url = encodeURIComponent(location.href)
    }

    switch (site) {
      case 'twitter': {
        const hashtags = encodeURIComponent(el.getAttribute(`data-${site}-hashtags`) || $parent.getAttribute('data-hashtags') || '')
        let viaStr = ''
        if (via.length > 0) viaStr = `&via=${via}`
        return SocialShareButton.openUrl(`https://twitter.com/intent/tweet?url=${url}&text=${title}&hashtags=${hashtags}${viaStr}`, 650, 300)
      }
      case 'facebook':
        return SocialShareButton.openUrl(`http://www.facebook.com/sharer/sharer.php?u=${url}`, 555, 400)
      case 'google_bookmark':
        return SocialShareButton.openUrl(`https://www.google.com/bookmarks/mark?op=edit&output=popup&bkmk=${url}&title=${title}`)
      case 'tumblr': {
        const getTumblrExtra = (param) => {
          const customData = el.getAttribute(`data-${param}`)
          return customData ? encodeURIComponent(customData) : undefined
        }
        const path = getTumblrExtra('type') || 'link'
        let params
        if (path === 'text') {
          const t = getTumblrExtra('title') || title
          params = `title=${t}`
        } else if (path === 'photo') {
          const t = getTumblrExtra('caption') || title
          const source = getTumblrExtra('source') || img
          params = `caption=${t}&source=${source}`
        } else if (path === 'quote') {
          const quote = getTumblrExtra('quote') || title
          const source = getTumblrExtra('source') || ''
          params = `quote=${quote}&source=${source}`
        } else {
          const t = getTumblrExtra('title') || title
          const u = getTumblrExtra('url') || url
          params = `name=${t}&url=${u}`
        }
        return SocialShareButton.openUrl(`http://www.tumblr.com/share/${path}?${params}`)
      }
      default:
        return false
    }
  }
}

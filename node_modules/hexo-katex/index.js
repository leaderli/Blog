'use strict'

var katex = require('katex')
var util = require('hexo-util')
var cheerio

hexo.extend.filter.register('after_post_render', function(data) {
  var hexo = this,
    options = hexo.config.katex || {}

  var content = data.content
  var linkTag = ''

  if (!cheerio) cheerio = require('cheerio')

  var $ = cheerio.load(data.content, { decodeEntities: true })

  if ($('.math').length > 0) {
    linkTag = util.htmlTag('link', {
      rel: 'stylesheet',
      href: 'https://cdn.jsdelivr.net/npm/katex@0.10.1/dist/katex.min.css',
      integrity:
        'sha384-dbVIfZGuN1Yq7/1Ocstc1lUEm+AT+/rCkibIcC/OmWo5f0EA48Vf8CytHzGrSwbQ',
      crossorigin: 'anonymous',
    })
  }

  $('.math.inline').each(function() {
    var html = katex.renderToString($(this).text(), {
      throwOnError: options.throw_on_error === undefined || options.throw_on_error,
      macros: options.macros,
    })
    $(this).replaceWith(html)
  })

  $('.math.display').each(function() {
    var html = katex.renderToString($(this).text(), {
      throwOnError: options.throw_on_error === undefined || options.throw_on_error,
      macros: options.macros,
      displayMode: true,
    })
    $(this).replaceWith(html)
  })

  if (options && options.css === false) {
    data.content = $.html()
  } else {
    data.content = linkTag + $.html()
  }
})

<div class="copyright">{#
#}{% set current = date(Date.now(), "YYYY") %}{#
#}{% if theme.footer.beian.enable %}{#
#}  {{ next_url('http://www.beian.miit.gov.cn', theme.footer.beian.icp + ' ') }}{#
#}{% endif %}{#
#}&copy; {% if theme.footer.since and theme.footer.since != current %}{{ theme.footer.since }} – {% endif %}{#
#}<span itemprop="copyrightYear">{{ current }}</span>
  <span class="with-love" id="animate">
    <i class="fa fa-{{ theme.footer.icon.name }}"></i>
  </span>
  <span class="author" itemprop="copyrightHolder">{{ theme.footer.copyright || author }}</span>

  {% if config.symbols_count_time.total_symbols %}
    <span class="post-meta-divider">|</span>
    <span class="post-meta-item-icon">
      <i class="fa fa-area-chart"></i>
    </span>
    {% if theme.symbols_count_time.item_text_total %}
      <span class="post-meta-item-text">{{ __('symbols_count_time.count_total') + __('symbol.colon') }}</span>
    {% endif %}
    <span title="{{ __('symbols_count_time.count_total') }}">{#
    #}{{ symbolsCountTotal(site) }}{#
  #}</span>
  {% endif %}

  {% if config.symbols_count_time.total_time %}
    <span class="post-meta-divider">|</span>
    <span class="post-meta-item-icon">
      <i class="fa fa-coffee"></i>
    </span>
    {% if theme.symbols_count_time.item_text_total %}
      <span class="post-meta-item-text">{{ __('symbols_count_time.time_total')}} &asymp;</span>
    {% endif %}
    <span title="{{ __('symbols_count_time.time_total') }}">{#
    #}{{ symbolsTimeTotal(site, theme.symbols_count_time.awl, theme.symbols_count_time.wpm, __('symbols_count_time.time_minutes')) }}{#
  #}</span>
  {% endif %}
</div>

{% if theme.footer.powered.enable %}
  <div class="powered-by">{#
  #}{{ __('footer.powered', next_url('https://hexo.io', 'Hexo', {class: 'theme-link'})) }}{#
  #}{% if theme.footer.powered.version %} v{{ hexo_env('version') }}{% endif %}{#
 #}</div>
{% endif %}

{% if theme.footer.powered.enable and theme.footer.theme.enable %}
  <span class="post-meta-divider">|</span>
{% endif %}

{% if theme.footer.theme.enable %}
  <div class="theme-info">{#
  #}{{ __('footer.theme') }} – {{ next_url('https://theme-next.org', 'NexT.' + theme.scheme, {class: 'theme-link'}) }}{#
  #}{% if theme.footer.theme.version %} v{{ version }}{% endif %}{#
#}</div>
{% endif %}

{% if theme.footer.custom_text %}
  <div class="footer-custom">{#
  #}{{ theme.footer.custom_text }}{#
#}</div>
{% endif %}

{% if theme.li_echarts %}

<script src="/js/echarts.min.js"></script>

<script>
    function recursion_tree(dom, tree) {
        tree = tree || {}
        if (dom.tagName === 'UL') {
            tree.children = []
            Array.prototype.forEach.call(dom.children, child => {
                tree.children.push(recursion_tree(child))
            })
            return tree;
        } else if (dom.tagName === 'LI') {
            html = dom.innerHTML
            tree.name = html;
            var ulIndex = html.indexOf('<')
            if (ulIndex > 0) {
                tree.name = html.substring(0, ulIndex).trim()
                Array.prototype.forEach.call(dom.children, child => {
                    console.log(child)
                    console.log(recursion_tree(child, tree))

                })
            }
            return tree
        } else {

        }
    }
    var title = document.querySelector('.post-title').innerText.trim()

    Array.prototype.forEach.call(document.getElementsByClassName("li-echarts-tree"), function (dom) {
        dom = dom.children[0]
        data = recursion_tree(dom, { "name": title })
        var div = document.createElement('div')
        div.setAttribute('style', 'width: 600px;height:400px;')
        dom.innerHTML=''
        dom.appendChild(div);
        var myChart = echarts.init(div);
        myChart.setOption(option = {
            tooltip: {
                trigger: 'item',
                triggerOn: 'mousemove'
            },
            series: [
                {
                    type: 'tree',

                    data: [data],

                    top: '1%',
                    left: '7%',
                    bottom: '1%',
                    right: '20%',

                    symbolSize: 7,

                    label: {
                        position: 'left',
                        verticalAlign: 'middle',
                        align: 'right',
                        fontSize: 9
                    },

                    leaves: {
                        label: {
                            position: 'right',
                            verticalAlign: 'middle',
                            align: 'left'
                        }
                    },

                    expandAndCollapse: false,
                    animationDuration: 350,
                    animationDurationUpdate: 450
                }
            ]
        });
    })
</script>
{% endif %}

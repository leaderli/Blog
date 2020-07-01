{% include 'algolia-search.swig' %}

{% if theme.local_search.li%}
  {% include 'li_localsearch.swig' %}
{% else %}
  {% include 'localsearch.swig' %}
{% endif %}

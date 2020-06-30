<div class="popup search-popup local-search-popup">
  <div class="local-search-header clearfix">
    <span class="search-icon">
      <i class="fa fa-search"></i>
    </span>
    <span class="popup-btn-close">
      <i class="fa fa-times-circle"></i>
    </span>
    <div class="local-search-input-wrapper">
      <input autocomplete="off"
             placeholder="{{ __('search.placeholder') }}" spellcheck="false"
             type="text" id="local-search-input">
    </div>
  </div>
  <div id="local-search-result"></div>
  <script type="text/javascript">
     var search_path = "<%= config.search.path %>";
     if (search_path.length == 0) {
     	search_path = "search.json";
     }
     var path = "<%= config.root %>" + search_path;
     searchFunc(path, 'local-search-input', 'local-search-result');
 </script>
</div>

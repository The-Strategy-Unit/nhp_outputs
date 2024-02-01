# ui is created correctly

    Code
      app_ui()
    Output
      <body data-help="1" data-fullscreen="0" data-dark="1" data-scrollToTop="0" class="sidebar-mini">
        <div class="wrapper">
          <nav data-fixed="false" class="main-header navbar navbar-expand navbar-white navbar-light">
            <ul class="navbar-nav">
              <li class="nav-item">
                <a class="nav-link" data-widget="pushmenu" href="#">
                  <i class="fas fa-bars" role="presentation" aria-label="bars icon" verify_fa="FALSE"></i>
                </a>
              </li>
            </ul>
            <ul class="navbar-nav ml-auto navbar-right">
              <li class="nav-item">
                <a id="controlbar-toggle" class="nav-link" data-widget="control-sidebar" href="#">
                  <i class="fas fa-table-cells" role="presentation" aria-label="table-cells icon" verify_fa="FALSE"></i>
                </a>
              </li>
            </ul>
          </nav>
          <aside id="sidebarId" data-fixed="true" data-minified="TRUE" data-collapsed="FALSE" data-disable="FALSE" class="main-sidebar sidebar-light-primary elevation-4">
            <div class="brand-link">NHP Model Results</div>
            <div class="sidebar" id="sidebarItemExpanded">
              <nav class="mt-2">
                <ul class="nav nav-pills nav-sidebar flex-column sidebar-menu nav-child-indent" data-widget="treeview" role="menu" data-accordion="true">
                  <li class="nav-item">
                    <a class="nav-link" id="tab-tab_home" href="#" data-target="#shiny-tab-tab_home" data-toggle="tab" data-value="tab_home">
                      <i class="fas fa-house nav-icon" role="presentation" aria-label="house icon" verify_fa="FALSE"></i>
                      <p>Home</p>
                    </a>
                  </li>
                  <li class="nav-item has-treeview">
                    <a href="#" class="nav-link">
                      <p>
                        Principal projection
                        <i class="right fas fa-angle-left"></i>
                      </p>
                    </a>
                    <ul class="nav nav-treeview" data-expanded="Principalprojection">
                      <li class="nav-item">
                        <a class="nav-link treeview-link" id="tab-tab_ps" href="#" data-target="#shiny-tab-tab_ps" data-toggle="tab" data-value="tab_ps">
                          <i class="fas fa-angles-right" role="presentation" aria-label="angles-right icon" verify_fa="FALSE" cl="fas fa-angles-right nav-icon"></i>
                          <p>Summary</p>
                        </a>
                      </li>
                      <li class="nav-item">
                        <a class="nav-link treeview-link" id="tab-tab_phl" href="#" data-target="#shiny-tab-tab_phl" data-toggle="tab" data-value="tab_phl">
                          <i class="fas fa-angles-right" role="presentation" aria-label="angles-right icon" verify_fa="FALSE" cl="fas fa-angles-right nav-icon"></i>
                          <p>Summary by year</p>
                        </a>
                      </li>
                      <li class="nav-item">
                        <a class="nav-link treeview-link" id="tab-tab_pg" href="#" data-target="#shiny-tab-tab_pg" data-toggle="tab" data-value="tab_pg">
                          <i class="fas fa-angles-right" role="presentation" aria-label="angles-right icon" verify_fa="FALSE" cl="fas fa-angles-right nav-icon"></i>
                          <p>Activity grouped</p>
                        </a>
                      </li>
                      <li class="nav-item">
                        <a class="nav-link treeview-link" id="tab-tab_pd" href="#" data-target="#shiny-tab-tab_pd" data-toggle="tab" data-value="tab_pd">
                          <i class="fas fa-angles-right" role="presentation" aria-label="angles-right icon" verify_fa="FALSE" cl="fas fa-angles-right nav-icon"></i>
                          <p>Activity in detail</p>
                        </a>
                      </li>
                      <li class="nav-item">
                        <a class="nav-link treeview-link" id="tab-tab_pcf" href="#" data-target="#shiny-tab-tab_pcf" data-toggle="tab" data-value="tab_pcf">
                          <i class="fas fa-angles-right" role="presentation" aria-label="angles-right icon" verify_fa="FALSE" cl="fas fa-angles-right nav-icon"></i>
                          <p>Impact of changes</p>
                        </a>
                      </li>
                      <li class="nav-item">
                        <a class="nav-link treeview-link" id="tab-tab_pcr" href="#" data-target="#shiny-tab-tab_pcr" data-toggle="tab" data-value="tab_pcr">
                          <i class="fas fa-angles-right" role="presentation" aria-label="angles-right icon" verify_fa="FALSE" cl="fas fa-angles-right nav-icon"></i>
                          <p>Capacity requirements</p>
                        </a>
                      </li>
                    </ul>
                  </li>
                  <li class="nav-item has-treeview">
                    <a href="#" class="nav-link">
                      <p>
                        Distribution of projections
                        <i class="right fas fa-angle-left"></i>
                      </p>
                    </a>
                    <ul class="nav nav-treeview" data-expanded="Distributionofprojections">
                      <li class="nav-item">
                        <a class="nav-link treeview-link" id="tab-tab_mc" href="#" data-target="#shiny-tab-tab_mc" data-toggle="tab" data-value="tab_mc">
                          <i class="fas fa-angles-right" role="presentation" aria-label="angles-right icon" verify_fa="FALSE" cl="fas fa-angles-right nav-icon"></i>
                          <p>Activity summary</p>
                        </a>
                      </li>
                      <li class="nav-item">
                        <a class="nav-link treeview-link" id="tab-tab_md" href="#" data-target="#shiny-tab-tab_md" data-toggle="tab" data-value="tab_md">
                          <i class="fas fa-angles-right" role="presentation" aria-label="angles-right icon" verify_fa="FALSE" cl="fas fa-angles-right nav-icon"></i>
                          <p>Activity distribution</p>
                        </a>
                      </li>
                      <li class="nav-item">
                        <a class="nav-link treeview-link" id="tab-tab_mcap" href="#" data-target="#shiny-tab-tab_mcap" data-toggle="tab" data-value="tab_mcap">
                          <i class="fas fa-angles-right" role="presentation" aria-label="angles-right icon" verify_fa="FALSE" cl="fas fa-angles-right nav-icon"></i>
                          <p>Capacity requirements</p>
                        </a>
                      </li>
                    </ul>
                  </li>
                  <li class="nav-item has-treeview">
                    <a href="#" class="nav-link">
                      <p>
                        Information
                        <i class="right fas fa-angle-left"></i>
                      </p>
                    </a>
                    <ul class="nav nav-treeview" data-expanded="Information">
                      <li class="nav-item">
                        <a class="nav-link treeview-link" id="tab-tab_params" href="#" data-target="#shiny-tab-tab_params" data-toggle="tab" data-value="tab_params">
                          <i class="fas fa-angles-right" role="presentation" aria-label="angles-right icon" verify_fa="FALSE" cl="fas fa-angles-right nav-icon"></i>
                          <p>Input parameters</p>
                        </a>
                      </li>
                    </ul>
                  </li>
                  <div id="sidebarMenu" class="sidebarMenuSelectedTabItem" data-value="null"></div>
                </ul>
              </nav>
            </div>
          </aside>
          <div class="content-wrapper">
            <section class="content">
              <div class="tab-content">
                <div role="tabpanel" class="tab-pane container-fluid" id="shiny-tab-tab_home">
                  <div class="row">
                    <div class="col-sm-6">
                      <h1>NHP Model</h1>
                    </div>
                    <div class="col-sm-6">
                      <div class="card bs4Dash">
                        <div class="card-header">
                          <h3 class="card-title">Results Selection</h3>
                          <div class="card-tools float-right">
                            <button class="btn btn-tool btn-sm" type="button" data-card-widget="collapse">
                              <i class="fas fa-minus" role="presentation" aria-label="minus icon" verify_fa="FALSE"></i>
                            </button>
                          </div>
                        </div>
                        <div class="card-body">result_selection</div>
                      </div>
                      <script type="application/json">{"title":"Results Selection","solidHeader":true,"width":6,"collapsible":true,"closable":false,"maximizable":false,"gradient":false}</script>
                    </div>
                  </div>
                </div>
                <div role="tabpanel" class="tab-pane container-fluid" id="shiny-tab-tab_ps">params_upload</div>
                <div role="tabpanel" class="tab-pane container-fluid" id="shiny-tab-tab_phl">running_models</div>
                <div role="tabpanel" class="tab-pane container-fluid" id="shiny-tab-tab_pg">
                  <h1>Principal projection: activity grouped</h1>
                  <div class="col-sm-12">
                    <div class="card bs4Dash">
                      <div class="card-header border-0">
                        <h3 class="card-title"></h3>
                      </div>
                      <div class="card-body">
                        <div class="row">
                          <div class="col-sm-3">
                            <div class="form-group shiny-input-container">
                              <label class="control-label" id="principal_grouped-measure_selection-activity_type-label" for="principal_grouped-measure_selection-activity_type">Activity Type</label>
                              <div>
                                <select id="principal_grouped-measure_selection-activity_type" class="shiny-input-select"></select>
                                <script type="application/json" data-for="principal_grouped-measure_selection-activity_type" data-nonempty="">{"plugins":["selectize-plugin-a11y"]}</script>
                              </div>
                            </div>
                          </div>
                          <div class="col-sm-3">
                            <div class="form-group shiny-input-container">
                              <label class="control-label" id="principal_grouped-measure_selection-pod-label" for="principal_grouped-measure_selection-pod">Point of Delivery</label>
                              <div>
                                <select id="principal_grouped-measure_selection-pod" class="shiny-input-select"></select>
                                <script type="application/json" data-for="principal_grouped-measure_selection-pod" data-nonempty="">{"plugins":["selectize-plugin-a11y"]}</script>
                              </div>
                            </div>
                          </div>
                          <div class="col-sm-3">
                            <div class="form-group shiny-input-container">
                              <label class="control-label" id="principal_grouped-measure_selection-measure-label" for="principal_grouped-measure_selection-measure">Measure</label>
                              <div>
                                <select id="principal_grouped-measure_selection-measure" class="shiny-input-select"></select>
                                <script type="application/json" data-for="principal_grouped-measure_selection-measure" data-nonempty="">{"plugins":["selectize-plugin-a11y"]}</script>
                              </div>
                            </div>
                          </div>
                        </div>
                      </div>
                    </div>
                    <script type="application/json">{"solidHeader":true,"width":12,"collapsible":false,"closable":false,"maximizable":false,"gradient":false}</script>
                  </div>
                  <div class="col-sm-12">
                    <div class="card bs4Dash">
                      <div class="card-header border-0">
                        <h3 class="card-title"></h3>
                      </div>
                      <div class="card-body">
                        <div class="shiny-spinner-output-container shiny-spinner-hideui ">
                          <div class="load-container shiny-spinner-hidden load1">
                            <div id="spinner-69c720310a602848aeff5d920323ca13" class="loader">Loading...</div>
                          </div>
                          <div style="height:400px" class="shiny-spinner-placeholder"></div>
                          <div id="principal_grouped-results" class="shiny-html-output"></div>
                        </div>
                      </div>
                    </div>
                    <script type="application/json">{"solidHeader":true,"width":12,"collapsible":false,"closable":false,"maximizable":false,"gradient":false}</script>
                  </div>
                </div>
                <div role="tabpanel" class="tab-pane container-fluid" id="shiny-tab-tab_pd">principal_summary</div>
                <div role="tabpanel" class="tab-pane container-fluid" id="shiny-tab-tab_pcf">principal_high_level</div>
                <div role="tabpanel" class="tab-pane container-fluid" id="shiny-tab-tab_pcr">principal_detailed</div>
                <div role="tabpanel" class="tab-pane container-fluid" id="shiny-tab-tab_mc">principal_change_factor_effects</div>
                <div role="tabpanel" class="tab-pane container-fluid" id="shiny-tab-tab_md">principal_capacity_requirements</div>
                <div role="tabpanel" class="tab-pane container-fluid" id="shiny-tab-tab_mcap">model_core_activity</div>
                <div role="tabpanel" class="tab-pane container-fluid" id="shiny-tab-tab_params">
                  <h1>Information: parameter inputs</h1>
                  <div class="col-sm-12">
                    <div class="card bs4Dash collapsed-card">
                      <div class="card-header">
                        <h3 class="card-title">Meta information</h3>
                        <div class="card-tools float-right">
                          <button class="btn btn-tool btn-sm" type="button" data-card-widget="collapse">
                            <i class="fas fa-plus" role="presentation" aria-label="plus icon" verify_fa="FALSE"></i>
                          </button>
                        </div>
                      </div>
                      <div class="card-body">
                        <pre class="shiny-text-output noplaceholder" id="info_params-params_meta"></pre>
                      </div>
                    </div>
                    <script type="application/json">{"title":"Meta information","solidHeader":true,"width":12,"collapsible":true,"closable":false,"maximizable":false,"gradient":false}</script>
                  </div>
                  <div class="col-sm-12">
                    <div class="card bs4Dash collapsed-card">
                      <div class="card-header">
                        <h3 class="card-title">Demographic factors</h3>
                        <div class="card-tools float-right">
                          <button class="btn btn-tool btn-sm" type="button" data-card-widget="collapse">
                            <i class="fas fa-plus" role="presentation" aria-label="plus icon" verify_fa="FALSE"></i>
                          </button>
                        </div>
                      </div>
                      <div class="card-body">
                        <pre class="shiny-text-output noplaceholder" id="info_params-params_demographic_factors"></pre>
                      </div>
                    </div>
                    <script type="application/json">{"title":"Demographic factors","solidHeader":true,"width":12,"collapsible":true,"closable":false,"maximizable":false,"gradient":false}</script>
                  </div>
                  <div class="col-sm-12">
                    <div class="card bs4Dash collapsed-card">
                      <div class="card-header">
                        <h3 class="card-title">Baseline adjustment</h3>
                        <div class="card-tools float-right">
                          <button class="btn btn-tool btn-sm" type="button" data-card-widget="collapse">
                            <i class="fas fa-plus" role="presentation" aria-label="plus icon" verify_fa="FALSE"></i>
                          </button>
                        </div>
                      </div>
                      <div class="card-body">
                        <pre class="shiny-text-output noplaceholder" id="info_params-params_baseline_adjustment"></pre>
                      </div>
                    </div>
                    <script type="application/json">{"title":"Baseline adjustment","solidHeader":true,"width":12,"collapsible":true,"closable":false,"maximizable":false,"gradient":false}</script>
                  </div>
                  <div class="col-sm-12">
                    <div class="card bs4Dash collapsed-card">
                      <div class="card-header">
                        <h3 class="card-title">Covid adjustment</h3>
                        <div class="card-tools float-right">
                          <button class="btn btn-tool btn-sm" type="button" data-card-widget="collapse">
                            <i class="fas fa-plus" role="presentation" aria-label="plus icon" verify_fa="FALSE"></i>
                          </button>
                        </div>
                      </div>
                      <div class="card-body">
                        <pre class="shiny-text-output noplaceholder" id="info_params-params_covid_adjustment"></pre>
                      </div>
                    </div>
                    <script type="application/json">{"title":"Covid adjustment","solidHeader":true,"width":12,"collapsible":true,"closable":false,"maximizable":false,"gradient":false}</script>
                  </div>
                  <div class="col-sm-12">
                    <div class="card bs4Dash collapsed-card">
                      <div class="card-header">
                        <h3 class="card-title">Waiting list adjustment</h3>
                        <div class="card-tools float-right">
                          <button class="btn btn-tool btn-sm" type="button" data-card-widget="collapse">
                            <i class="fas fa-plus" role="presentation" aria-label="plus icon" verify_fa="FALSE"></i>
                          </button>
                        </div>
                      </div>
                      <div class="card-body">
                        <pre class="shiny-text-output noplaceholder" id="info_params-params_waiting_list_adjustment"></pre>
                      </div>
                    </div>
                    <script type="application/json">{"title":"Waiting list adjustment","solidHeader":true,"width":12,"collapsible":true,"closable":false,"maximizable":false,"gradient":false}</script>
                  </div>
                  <div class="col-sm-12">
                    <div class="card bs4Dash collapsed-card">
                      <div class="card-header">
                        <h3 class="card-title">Expatriation</h3>
                        <div class="card-tools float-right">
                          <button class="btn btn-tool btn-sm" type="button" data-card-widget="collapse">
                            <i class="fas fa-plus" role="presentation" aria-label="plus icon" verify_fa="FALSE"></i>
                          </button>
                        </div>
                      </div>
                      <div class="card-body">
                        <pre class="shiny-text-output noplaceholder" id="info_params-params_expat"></pre>
                      </div>
                    </div>
                    <script type="application/json">{"title":"Expatriation","solidHeader":true,"width":12,"collapsible":true,"closable":false,"maximizable":false,"gradient":false}</script>
                  </div>
                  <div class="col-sm-12">
                    <div class="card bs4Dash collapsed-card">
                      <div class="card-header">
                        <h3 class="card-title">Repatriation (local)</h3>
                        <div class="card-tools float-right">
                          <button class="btn btn-tool btn-sm" type="button" data-card-widget="collapse">
                            <i class="fas fa-plus" role="presentation" aria-label="plus icon" verify_fa="FALSE"></i>
                          </button>
                        </div>
                      </div>
                      <div class="card-body">
                        <pre class="shiny-text-output noplaceholder" id="info_params-params_repat_local"></pre>
                      </div>
                    </div>
                    <script type="application/json">{"title":"Repatriation (local)","solidHeader":true,"width":12,"collapsible":true,"closable":false,"maximizable":false,"gradient":false}</script>
                  </div>
                  <div class="col-sm-12">
                    <div class="card bs4Dash collapsed-card">
                      <div class="card-header">
                        <h3 class="card-title">Repatriation (non-local)</h3>
                        <div class="card-tools float-right">
                          <button class="btn btn-tool btn-sm" type="button" data-card-widget="collapse">
                            <i class="fas fa-plus" role="presentation" aria-label="plus icon" verify_fa="FALSE"></i>
                          </button>
                        </div>
                      </div>
                      <div class="card-body">
                        <pre class="shiny-text-output noplaceholder" id="info_params-params_repat_nonlocal"></pre>
                      </div>
                    </div>
                    <script type="application/json">{"title":"Repatriation (non-local)","solidHeader":true,"width":12,"collapsible":true,"closable":false,"maximizable":false,"gradient":false}</script>
                  </div>
                  <div class="col-sm-12">
                    <div class="card bs4Dash collapsed-card">
                      <div class="card-header">
                        <h3 class="card-title">Non-demographic adjustment</h3>
                        <div class="card-tools float-right">
                          <button class="btn btn-tool btn-sm" type="button" data-card-widget="collapse">
                            <i class="fas fa-plus" role="presentation" aria-label="plus icon" verify_fa="FALSE"></i>
                          </button>
                        </div>
                      </div>
                      <div class="card-body">
                        <pre class="shiny-text-output noplaceholder" id="info_params-params_non_demographic_adjustment"></pre>
                      </div>
                    </div>
                    <script type="application/json">{"title":"Non-demographic adjustment","solidHeader":true,"width":12,"collapsible":true,"closable":false,"maximizable":false,"gradient":false}</script>
                  </div>
                  <div class="col-sm-12">
                    <div class="card bs4Dash collapsed-card">
                      <div class="card-header">
                        <h3 class="card-title">Activity avoidance</h3>
                        <div class="card-tools float-right">
                          <button class="btn btn-tool btn-sm" type="button" data-card-widget="collapse">
                            <i class="fas fa-plus" role="presentation" aria-label="plus icon" verify_fa="FALSE"></i>
                          </button>
                        </div>
                      </div>
                      <div class="card-body">
                        <pre class="shiny-text-output noplaceholder" id="info_params-params_activity_avoidance"></pre>
                      </div>
                    </div>
                    <script type="application/json">{"title":"Activity avoidance","solidHeader":true,"width":12,"collapsible":true,"closable":false,"maximizable":false,"gradient":false}</script>
                  </div>
                  <div class="col-sm-12">
                    <div class="card bs4Dash collapsed-card">
                      <div class="card-header">
                        <h3 class="card-title">Efficiences</h3>
                        <div class="card-tools float-right">
                          <button class="btn btn-tool btn-sm" type="button" data-card-widget="collapse">
                            <i class="fas fa-plus" role="presentation" aria-label="plus icon" verify_fa="FALSE"></i>
                          </button>
                        </div>
                      </div>
                      <div class="card-body">
                        <pre class="shiny-text-output noplaceholder" id="info_params-params_efficiencies"></pre>
                      </div>
                    </div>
                    <script type="application/json">{"title":"Efficiences","solidHeader":true,"width":12,"collapsible":true,"closable":false,"maximizable":false,"gradient":false}</script>
                  </div>
                  <div class="col-sm-12">
                    <div class="card bs4Dash collapsed-card">
                      <div class="card-header">
                        <h3 class="card-title">Bed occupancy</h3>
                        <div class="card-tools float-right">
                          <button class="btn btn-tool btn-sm" type="button" data-card-widget="collapse">
                            <i class="fas fa-plus" role="presentation" aria-label="plus icon" verify_fa="FALSE"></i>
                          </button>
                        </div>
                      </div>
                      <div class="card-body">
                        <pre class="shiny-text-output noplaceholder" id="info_params-params_bed_occupancy"></pre>
                      </div>
                    </div>
                    <script type="application/json">{"title":"Bed occupancy","solidHeader":true,"width":12,"collapsible":true,"closable":false,"maximizable":false,"gradient":false}</script>
                  </div>
                  <div class="col-sm-12">
                    <div class="card bs4Dash collapsed-card">
                      <div class="card-header">
                        <h3 class="card-title">Time profile mappings</h3>
                        <div class="card-tools float-right">
                          <button class="btn btn-tool btn-sm" type="button" data-card-widget="collapse">
                            <i class="fas fa-plus" role="presentation" aria-label="plus icon" verify_fa="FALSE"></i>
                          </button>
                        </div>
                      </div>
                      <div class="card-body">
                        <pre class="shiny-text-output noplaceholder" id="info_params-params_time_profile_mappings"></pre>
                      </div>
                    </div>
                    <script type="application/json">{"title":"Time profile mappings","solidHeader":true,"width":12,"collapsible":true,"closable":false,"maximizable":false,"gradient":false}</script>
                  </div>
                </div>
              </div>
            </section>
          </div>
        </div>
      </body>


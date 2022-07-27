# ui is created correctly

    Code
      app_ui()
    Output
      <body data-help="0" data-fullscreen="0" data-dark="1" data-scrollToTop="0">
        <div class="wrapper">
          <nav data-fixed="false" class="main-header navbar navbar-expand navbar-white navbar-light">
            <ul class="navbar-nav">
              <li class="nav-item">
                <a class="nav-link" data-widget="pushmenu" href="#">
                  <i class="fa fa-bars" role="presentation" aria-label="bars icon"></i>
                </a>
              </li>
            </ul>
            <ul class="navbar-nav ml-auto navbar-right">
              <li class="nav-item">
                <a id="controlbar-toggle" class="nav-link" data-widget="control-sidebar" href="#">
                  <i class="fa fa-th" role="presentation" aria-label="th icon"></i>
                </a>
              </li>
            </ul>
          </nav>
          <aside id="sidebarId" data-fixed="true" data-minified="true" data-collapsed="false" data-disable="FALSE" class="main-sidebar sidebar-light-primary elevation-4">
            <div class="brand-link">NHP Model Results</div>
            <div class="sidebar" id="sidebarItemExpanded">
              <nav class="mt-2">
                <ul class="nav nav-pills nav-sidebar flex-column sidebar-menu nav-child-indent" data-widget="treeview" role="menu" data-accordion="true">
                  <li class="nav-item">
                    <a class="nav-link" id="tab-tab_home" href="#" data-target="#shiny-tab-tab_home" data-toggle="tab" data-value="tab_home">
                      <i class="fa fa-home nav-icon" role="presentation" aria-label="home icon"></i>
                      <p>Home</p>
                    </a>
                  </li>
                  <li class="nav-item has-treeview">
                    <a href="#" class="nav-link">
                      <p>
                        Principal Projection
                        <i class="right fas fa-angle-left"></i>
                      </p>
                    </a>
                    <ul class="nav nav-treeview" data-expanded="PrincipalProjection">
                      <li class="nav-item">
                        <a class="nav-link treeview-link" id="tab-tab_phl" href="#" data-target="#shiny-tab-tab_phl" data-toggle="tab" data-value="tab_phl">
                          <i class="fa fa-angle-double-right" role="presentation" aria-label="angle-double-right icon" cl="fa fa-angle-double-right nav-icon"></i>
                          <p>High Level</p>
                        </a>
                      </li>
                      <li class="nav-item">
                        <a class="nav-link treeview-link" id="tab-tab_pd" href="#" data-target="#shiny-tab-tab_pd" data-toggle="tab" data-value="tab_pd">
                          <i class="fa fa-angle-double-right" role="presentation" aria-label="angle-double-right icon" cl="fa fa-angle-double-right nav-icon"></i>
                          <p>Detailed</p>
                        </a>
                      </li>
                      <li class="nav-item">
                        <a class="nav-link treeview-link" id="tab-tab_pcf" href="#" data-target="#shiny-tab-tab_pcf" data-toggle="tab" data-value="tab_pcf">
                          <i class="fa fa-angle-double-right" role="presentation" aria-label="angle-double-right icon" cl="fa fa-angle-double-right nav-icon"></i>
                          <p>Change Factors</p>
                        </a>
                      </li>
                    </ul>
                  </li>
                  <li class="nav-item has-treeview">
                    <a href="#" class="nav-link">
                      <p>
                        Model Results
                        <i class="right fas fa-angle-left"></i>
                      </p>
                    </a>
                    <ul class="nav nav-treeview" data-expanded="ModelResults">
                      <li class="nav-item">
                        <a class="nav-link treeview-link" id="tab-tab_mc" href="#" data-target="#shiny-tab-tab_mc" data-toggle="tab" data-value="tab_mc">
                          <i class="fa fa-angle-double-right" role="presentation" aria-label="angle-double-right icon" cl="fa fa-angle-double-right nav-icon"></i>
                          <p>Core Activity</p>
                        </a>
                      </li>
                      <li class="nav-item">
                        <a class="nav-link treeview-link" id="tab-tab_md" href="#" data-target="#shiny-tab-tab_md" data-toggle="tab" data-value="tab_md">
                          <i class="fa fa-angle-double-right" role="presentation" aria-label="angle-double-right icon" cl="fa fa-angle-double-right nav-icon"></i>
                          <p>Results Distribution</p>
                        </a>
                      </li>
                    </ul>
                  </li>
                  <li class="nav-item has-treeview">
                    <a href="#" class="nav-link">
                      <p>
                        Capacity Conversion
                        <i class="right fas fa-angle-left"></i>
                      </p>
                    </a>
                    <ul class="nav nav-treeview" data-expanded="CapacityConversion">
                      <li class="nav-item">
                        <a class="nav-link treeview-link" id="tab-tab_cb" href="#" data-target="#shiny-tab-tab_cb" data-toggle="tab" data-value="tab_cb">
                          <i class="fa fa-angle-double-right" role="presentation" aria-label="angle-double-right icon" cl="fa fa-angle-double-right nav-icon"></i>
                          <p>Beds</p>
                        </a>
                      </li>
                      <li class="nav-item">
                        <a class="nav-link treeview-link" id="tab-tab_ct" href="#" data-target="#shiny-tab-tab_ct" data-toggle="tab" data-value="tab_ct">
                          <i class="fa fa-angle-double-right" role="presentation" aria-label="angle-double-right icon" cl="fa fa-angle-double-right nav-icon"></i>
                          <p>Theatres</p>
                        </a>
                      </li>
                    </ul>
                  </li>
                  <hr/>
                  <li class="nav-item has-treeview">
                    <a href="#" class="nav-link">
                      <p>
                        Run Model
                        <i class="right fas fa-angle-left"></i>
                      </p>
                    </a>
                    <ul class="nav nav-treeview" data-expanded="RunModel">
                      <li class="nav-item">
                        <a class="nav-link treeview-link" id="tab-tab_up" href="#" data-target="#shiny-tab-tab_up" data-toggle="tab" data-value="tab_up">
                          <i class="fa fa-sliders-h" role="presentation" aria-label="sliders-h icon" cl="fa fa-sliders-h nav-icon"></i>
                          <p>Upload Params</p>
                        </a>
                      </li>
                      <li class="nav-item">
                        <a class="nav-link treeview-link" id="tab-tab_rm" href="#" data-target="#shiny-tab-tab_rm" data-toggle="tab" data-value="tab_rm">
                          <i class="fa fa-running" role="presentation" aria-label="running icon" cl="fa fa-running nav-icon"></i>
                          <p>Running Models</p>
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
                              <i class="fa fa-minus" role="presentation" aria-label="minus icon"></i>
                            </button>
                          </div>
                        </div>
                        <div class="card-body">result_selection</div>
                      </div>
                      <script type="application/json">{"title":"Results Selection","solidHeader":true,"width":6,"collapsible":true,"closable":false,"maximizable":false,"gradient":false}</script>
                    </div>
                  </div>
                </div>
                <div role="tabpanel" class="tab-pane container-fluid" id="shiny-tab-tab_up">params_upload</div>
                <div role="tabpanel" class="tab-pane container-fluid" id="shiny-tab-tab_rm">running_models</div>
                <div role="tabpanel" class="tab-pane container-fluid" id="shiny-tab-tab_phl">principal_high_level</div>
                <div role="tabpanel" class="tab-pane container-fluid" id="shiny-tab-tab_pd">principal_detailed</div>
                <div role="tabpanel" class="tab-pane container-fluid" id="shiny-tab-tab_pcf">principal_change_factor_effects</div>
                <div role="tabpanel" class="tab-pane container-fluid" id="shiny-tab-tab_mc">model_core_activity</div>
                <div role="tabpanel" class="tab-pane container-fluid" id="shiny-tab-tab_md">model_results_distribution</div>
                <div role="tabpanel" class="tab-pane container-fluid" id="shiny-tab-tab_cb">capacity_beds</div>
                <div role="tabpanel" class="tab-pane container-fluid" id="shiny-tab-tab_ct">
                  <div class="row">
                    <div class="col-sm-12">
                      <div class="card bs4Dash">
                        <div class="card-header">
                          <h3 class="card-title">Theatres Available</h3>
                          <div class="card-tools float-right">
                            <button class="btn btn-tool btn-sm" type="button" data-card-widget="collapse">
                              <i class="fa fa-minus" role="presentation" aria-label="minus icon"></i>
                            </button>
                          </div>
                        </div>
                        <div class="card-body">
                          <span>
                            Available (baseline): 
                            <div id="capacity_theatres-available_baseline" class="shiny-text-output"></div>
                          </span>
                          <span>
                            Available (principal): 
                            <div id="capacity_theatres-available_principal" class="shiny-text-output"></div>
                          </span>
                        </div>
                      </div>
                      <script type="application/json">{"title":"Theatres Available","solidHeader":true,"width":12,"collapsible":true,"closable":false,"maximizable":false,"gradient":false}</script>
                    </div>
                    <div class="col-sm-12">
                      <div class="card bs4Dash">
                        <div class="card-header">
                          <h3 class="card-title">Four Hour Sesssions</h3>
                        </div>
                        <div class="card-body">
                          <div class="col-sm-9">
                            <div class="shiny-spinner-output-container shiny-spinner-hideui ">
                              <div class="load-container shiny-spinner-hidden load1">
                                <div id="spinner-7ec8f6e80609c587d921f14a4331a9fe" class="loader">Loading...</div>
                              </div>
                              <div id="capacity_theatres-utilisation_plot" style="width:100%; height:800px; " class="plotly html-widget html-widget-output shiny-report-size shiny-report-theme"></div>
                            </div>
                          </div>
                          <div class="col-sm-3">
                            <div class="shiny-spinner-output-container shiny-spinner-hideui ">
                              <div class="load-container shiny-spinner-hidden load1">
                                <div id="spinner-da5faedd6df2eb3e7f464b72f75850b7" class="loader">Loading...</div>
                              </div>
                              <div style="height:400px" class="shiny-spinner-placeholder"></div>
                              <div id="capacity_theatres-utilisation_table" class="shiny-html-output"></div>
                            </div>
                          </div>
                        </div>
                      </div>
                      <script type="application/json">{"title":"Four Hour Sesssions","solidHeader":true,"width":12,"collapsible":false,"closable":false,"maximizable":false,"gradient":false}</script>
                    </div>
                  </div>
                </div>
              </div>
            </section>
          </div>
        </div>
      </body>


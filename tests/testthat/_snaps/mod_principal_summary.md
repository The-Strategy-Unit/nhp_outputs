# ui is created correctly

    Code
      mod_principal_summary_ui("id")
    Output
      <div class="row">
        <div class="col-sm-3"></div>
        <div class="col-sm-6">
          <div class="card bs4Dash">
            <div class="card-header">
              <h3 class="card-title">Summary</h3>
            </div>
            <div class="card-body">
              <div class="shiny-spinner-output-container shiny-spinner-hideui ">
                <div class="load-container shiny-spinner-hidden load1">
                  <div id="spinner-bca61015a8656c8b633239e1f4c01396" class="loader">Loading...</div>
                </div>
                <div style="height:400px" class="shiny-spinner-placeholder"></div>
                <div id="id-summary_table" class="shiny-html-output"></div>
              </div>
            </div>
          </div>
          <script type="application/json">{"title":"Summary","solidHeader":true,"width":6,"collapsible":false,"closable":false,"maximizable":false,"gradient":false}</script>
        </div>
        <div class="col-sm-3"></div>
      </div>

# mod_principal_summary_table creates a gt object

    Code
      mod_principal_summary_table(data)
    Output
      <div id="osncjrvket" style="padding-left:0px;padding-right:0px;padding-top:10px;padding-bottom:10px;overflow-x:auto;overflow-y:auto;width:auto;height:auto;">
        <style>html {
        font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, 'Helvetica Neue', 'Fira Sans', 'Droid Sans', Arial, sans-serif;
      }
      
      #osncjrvket .gt_table {
        display: table;
        border-collapse: collapse;
        margin-left: auto;
        margin-right: auto;
        color: #333333;
        font-size: 16px;
        font-weight: normal;
        font-style: normal;
        background-color: #FFFFFF;
        width: auto;
        border-top-style: solid;
        border-top-width: 2px;
        border-top-color: #FFFFFF;
        border-right-style: none;
        border-right-width: 2px;
        border-right-color: #D3D3D3;
        border-bottom-style: solid;
        border-bottom-width: 3px;
        border-bottom-color: #FFFFFF;
        border-left-style: none;
        border-left-width: 2px;
        border-left-color: #D3D3D3;
      }
      
      #osncjrvket .gt_heading {
        background-color: #FFFFFF;
        text-align: left;
        border-bottom-color: #FFFFFF;
        border-left-style: none;
        border-left-width: 1px;
        border-left-color: #D3D3D3;
        border-right-style: none;
        border-right-width: 1px;
        border-right-color: #D3D3D3;
      }
      
      #osncjrvket .gt_caption {
        padding-top: 4px;
        padding-bottom: 4px;
      }
      
      #osncjrvket .gt_title {
        color: #333333;
        font-size: 125%;
        font-weight: initial;
        padding-top: 4px;
        padding-bottom: 4px;
        padding-left: 5px;
        padding-right: 5px;
        border-bottom-color: #FFFFFF;
        border-bottom-width: 0;
      }
      
      #osncjrvket .gt_subtitle {
        color: #333333;
        font-size: 12px;
        font-weight: initial;
        padding-top: 0;
        padding-bottom: 6px;
        padding-left: 5px;
        padding-right: 5px;
        border-top-color: #FFFFFF;
        border-top-width: 0;
      }
      
      #osncjrvket .gt_bottom_border {
        border-bottom-style: solid;
        border-bottom-width: 2px;
        border-bottom-color: #D3D3D3;
      }
      
      #osncjrvket .gt_col_headings {
        border-top-style: solid;
        border-top-width: 2px;
        border-top-color: #D3D3D3;
        border-bottom-style: solid;
        border-bottom-width: 1px;
        border-bottom-color: #000000;
        border-left-style: none;
        border-left-width: 1px;
        border-left-color: #D3D3D3;
        border-right-style: none;
        border-right-width: 1px;
        border-right-color: #D3D3D3;
      }
      
      #osncjrvket .gt_col_heading {
        color: #333333;
        background-color: #FFFFFF;
        font-size: 100%;
        font-weight: normal;
        text-transform: inherit;
        border-left-style: none;
        border-left-width: 1px;
        border-left-color: #D3D3D3;
        border-right-style: none;
        border-right-width: 1px;
        border-right-color: #D3D3D3;
        vertical-align: bottom;
        padding-top: 5px;
        padding-bottom: 6px;
        padding-left: 5px;
        padding-right: 5px;
        overflow-x: hidden;
      }
      
      #osncjrvket .gt_column_spanner_outer {
        color: #333333;
        background-color: #FFFFFF;
        font-size: 100%;
        font-weight: normal;
        text-transform: inherit;
        padding-top: 0;
        padding-bottom: 0;
        padding-left: 4px;
        padding-right: 4px;
      }
      
      #osncjrvket .gt_column_spanner_outer:first-child {
        padding-left: 0;
      }
      
      #osncjrvket .gt_column_spanner_outer:last-child {
        padding-right: 0;
      }
      
      #osncjrvket .gt_column_spanner {
        border-bottom-style: solid;
        border-bottom-width: 1px;
        border-bottom-color: #000000;
        vertical-align: bottom;
        padding-top: 5px;
        padding-bottom: 5px;
        overflow-x: hidden;
        display: inline-block;
        width: 100%;
      }
      
      #osncjrvket .gt_group_heading {
        padding-top: 8px;
        padding-bottom: 8px;
        padding-left: 5px;
        padding-right: 5px;
        color: #333333;
        background-color: #FCDF83;
        font-size: 100%;
        font-weight: initial;
        text-transform: inherit;
        border-top-style: solid;
        border-top-width: 2px;
        border-top-color: #000000;
        border-bottom-style: solid;
        border-bottom-width: 2px;
        border-bottom-color: #000000;
        border-left-style: none;
        border-left-width: 1px;
        border-left-color: #D3D3D3;
        border-right-style: none;
        border-right-width: 1px;
        border-right-color: #D3D3D3;
        vertical-align: middle;
        text-align: left;
      }
      
      #osncjrvket .gt_empty_group_heading {
        padding: 0.5px;
        color: #333333;
        background-color: #FCDF83;
        font-size: 100%;
        font-weight: initial;
        border-top-style: solid;
        border-top-width: 2px;
        border-top-color: #000000;
        border-bottom-style: solid;
        border-bottom-width: 2px;
        border-bottom-color: #000000;
        vertical-align: middle;
      }
      
      #osncjrvket .gt_from_md > :first-child {
        margin-top: 0;
      }
      
      #osncjrvket .gt_from_md > :last-child {
        margin-bottom: 0;
      }
      
      #osncjrvket .gt_row {
        padding-top: 8px;
        padding-bottom: 8px;
        padding-left: 5px;
        padding-right: 5px;
        margin: 10px;
        border-top-style: solid;
        border-top-width: 1px;
        border-top-color: #FFFFFF;
        border-left-style: none;
        border-left-width: 1px;
        border-left-color: #D3D3D3;
        border-right-style: none;
        border-right-width: 1px;
        border-right-color: #D3D3D3;
        vertical-align: middle;
        overflow-x: hidden;
      }
      
      #osncjrvket .gt_stub {
        color: #333333;
        background-color: #FFFFFF;
        font-size: 100%;
        font-weight: initial;
        text-transform: inherit;
        border-right-style: solid;
        border-right-width: 2px;
        border-right-color: #D3D3D3;
        padding-left: 5px;
        padding-right: 5px;
      }
      
      #osncjrvket .gt_stub_row_group {
        color: #333333;
        background-color: #FFFFFF;
        font-size: 100%;
        font-weight: initial;
        text-transform: inherit;
        border-right-style: solid;
        border-right-width: 2px;
        border-right-color: #D3D3D3;
        padding-left: 5px;
        padding-right: 5px;
        vertical-align: top;
      }
      
      #osncjrvket .gt_row_group_first td {
        border-top-width: 2px;
      }
      
      #osncjrvket .gt_summary_row {
        color: #333333;
        background-color: #FFFFFF;
        text-transform: inherit;
        padding-top: 8px;
        padding-bottom: 8px;
        padding-left: 5px;
        padding-right: 5px;
      }
      
      #osncjrvket .gt_first_summary_row {
        border-top-style: solid;
        border-top-color: #D3D3D3;
      }
      
      #osncjrvket .gt_first_summary_row.thick {
        border-top-width: 2px;
      }
      
      #osncjrvket .gt_last_summary_row {
        padding-top: 8px;
        padding-bottom: 8px;
        padding-left: 5px;
        padding-right: 5px;
        border-bottom-style: solid;
        border-bottom-width: 2px;
        border-bottom-color: #D3D3D3;
      }
      
      #osncjrvket .gt_grand_summary_row {
        color: #333333;
        background-color: #FFFFFF;
        text-transform: inherit;
        padding-top: 8px;
        padding-bottom: 8px;
        padding-left: 5px;
        padding-right: 5px;
      }
      
      #osncjrvket .gt_first_grand_summary_row {
        padding-top: 8px;
        padding-bottom: 8px;
        padding-left: 5px;
        padding-right: 5px;
        border-top-style: double;
        border-top-width: 6px;
        border-top-color: #D3D3D3;
      }
      
      #osncjrvket .gt_striped {
        background-color: rgba(128, 128, 128, 0.05);
      }
      
      #osncjrvket .gt_table_body {
        border-top-style: solid;
        border-top-width: 2px;
        border-top-color: #D3D3D3;
        border-bottom-style: solid;
        border-bottom-width: 2px;
        border-bottom-color: #D3D3D3;
      }
      
      #osncjrvket .gt_footnotes {
        color: #333333;
        background-color: #FFFFFF;
        border-bottom-style: none;
        border-bottom-width: 2px;
        border-bottom-color: #D3D3D3;
        border-left-style: none;
        border-left-width: 2px;
        border-left-color: #D3D3D3;
        border-right-style: none;
        border-right-width: 2px;
        border-right-color: #D3D3D3;
      }
      
      #osncjrvket .gt_footnote {
        margin: 0px;
        font-size: 90%;
        padding-left: 4px;
        padding-right: 4px;
        padding-left: 5px;
        padding-right: 5px;
      }
      
      #osncjrvket .gt_sourcenotes {
        color: #333333;
        background-color: #FFFFFF;
        border-bottom-style: none;
        border-bottom-width: 2px;
        border-bottom-color: #D3D3D3;
        border-left-style: none;
        border-left-width: 2px;
        border-left-color: #D3D3D3;
        border-right-style: none;
        border-right-width: 2px;
        border-right-color: #D3D3D3;
      }
      
      #osncjrvket .gt_sourcenote {
        font-size: 90%;
        padding-top: 4px;
        padding-bottom: 4px;
        padding-left: 5px;
        padding-right: 5px;
      }
      
      #osncjrvket .gt_left {
        text-align: left;
      }
      
      #osncjrvket .gt_center {
        text-align: center;
      }
      
      #osncjrvket .gt_right {
        text-align: right;
        font-variant-numeric: tabular-nums;
      }
      
      #osncjrvket .gt_font_normal {
        font-weight: normal;
      }
      
      #osncjrvket .gt_font_bold {
        font-weight: bold;
      }
      
      #osncjrvket .gt_font_italic {
        font-style: italic;
      }
      
      #osncjrvket .gt_super {
        font-size: 65%;
      }
      
      #osncjrvket .gt_footnote_marks {
        font-style: italic;
        font-weight: normal;
        font-size: 75%;
        vertical-align: 0.4em;
      }
      
      #osncjrvket .gt_asterisk {
        font-size: 100%;
        vertical-align: 0;
      }
      
      #osncjrvket .gt_indent_1 {
        text-indent: 5px;
      }
      
      #osncjrvket .gt_indent_2 {
        text-indent: 10px;
      }
      
      #osncjrvket .gt_indent_3 {
        text-indent: 15px;
      }
      
      #osncjrvket .gt_indent_4 {
        text-indent: 20px;
      }
      
      #osncjrvket .gt_indent_5 {
        text-indent: 25px;
      }
      </style>
        <table class="gt_table">
        
        <thead class="gt_col_headings">
          <tr>
            <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" scope="col" id=""></th>
            <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" scope="col" id="baseline">baseline</th>
            <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" scope="col" id="principal">principal</th>
          </tr>
        </thead>
        <tbody class="gt_table_body">
          <tr><td headers="pod_name" class="gt_row gt_left">a</td>
      <td headers="baseline" class="gt_row gt_right">1</td>
      <td headers="principal" class="gt_row gt_right">4</td></tr>
          <tr><td headers="pod_name" class="gt_row gt_left">b</td>
      <td headers="baseline" class="gt_row gt_right">2</td>
      <td headers="principal" class="gt_row gt_right">5</td></tr>
          <tr><td headers="pod_name" class="gt_row gt_left">c</td>
      <td headers="baseline" class="gt_row gt_right">3</td>
      <td headers="principal" class="gt_row gt_right">6</td></tr>
        </tbody>
        
        
      </table>
      </div>


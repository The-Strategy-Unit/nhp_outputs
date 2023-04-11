# it produces correct bars

    Code
      gt_bar(1:2)
    Output
      [[1]]
      <div>
        <span style="display: inline-block; direction: ltr; border: 0; background-color: transparent; width: 0%">&nbsp;</span>
        <span style="display: inline-block; direction: ltr; border: 0; background-color: #f9bf07; width: 25%">&nbsp;</span>
        <span style="width: 50%" align="right">&nbsp;</span>
      </div>
      
      [[2]]
      <div>
        <span style="display: inline-block; direction: ltr; border: 0; background-color: transparent; width: 0%">&nbsp;</span>
        <span style="display: inline-block; direction: ltr; border: 0; background-color: #f9bf07; width: 50%">&nbsp;</span>
        <span style="width: 50%" align="right">&nbsp;</span>
      </div>
      

---

    Code
      gt_bar(1:2 / 10, scales::percent)
    Output
      [[1]]
      <div>
        <span style="display: inline-block; direction: ltr; border: 0; background-color: transparent; width: 0%">&nbsp;</span>
        <span style="display: inline-block; direction: ltr; border: 0; background-color: #f9bf07; width: 25%">&nbsp;</span>
        <span style="width: 50%" align="right">10%</span>
      </div>
      
      [[2]]
      <div>
        <span style="display: inline-block; direction: ltr; border: 0; background-color: transparent; width: 0%">&nbsp;</span>
        <span style="display: inline-block; direction: ltr; border: 0; background-color: #f9bf07; width: 50%">&nbsp;</span>
        <span style="width: 50%" align="right">20%</span>
      </div>
      

---

    Code
      gt_bar(-(1:2))
    Output
      [[1]]
      <div>
        <span style="display: inline-block; direction: ltr; border: 0; background-color: transparent; width: 25%">&nbsp;</span>
        <span style="display: inline-block; direction: ltr; border: 0; background-color: #ec6555; width: -25%">&nbsp;</span>
        <span style="width: 50%" align="right">&nbsp;</span>
      </div>
      
      [[2]]
      <div>
        <span style="display: inline-block; direction: ltr; border: 0; background-color: transparent; width: 50%">&nbsp;</span>
        <span style="display: inline-block; direction: ltr; border: 0; background-color: #ec6555; width: -50%">&nbsp;</span>
        <span style="width: 50%" align="right">&nbsp;</span>
      </div>
      

---

    Code
      gt_bar(-1:1)
    Output
      [[1]]
      <div>
        <span style="display: inline-block; direction: ltr; border: 0; background-color: transparent; width: 0%">&nbsp;</span>
        <span style="display: inline-block; direction: ltr; border: 0; background-color: #ec6555; width: 25%">&nbsp;</span>
        <span style="width: 50%" align="right">&nbsp;</span>
      </div>
      
      [[2]]
      <div>
        <span style="display: inline-block; direction: ltr; border: 0; background-color: transparent; width: 25%">&nbsp;</span>
        <span style="display: inline-block; direction: ltr; border: 0; background-color: #ec6555; width: 0%">&nbsp;</span>
        <span style="width: 50%" align="right">&nbsp;</span>
      </div>
      
      [[3]]
      <div>
        <span style="display: inline-block; direction: ltr; border: 0; background-color: transparent; width: 25%">&nbsp;</span>
        <span style="display: inline-block; direction: ltr; border: 0; background-color: #f9bf07; width: 25%">&nbsp;</span>
        <span style="width: 50%" align="right">&nbsp;</span>
      </div>
      


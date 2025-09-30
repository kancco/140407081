import {toast,qs,qsa} from './ui-common.js';

const tabsMap = {
  factories: {
    endpoint:'search_factories.php',
    title:'واحد تولیدی',
    columns:[
      {k:'factory_name_fa',t:'نام واحد تولیدی'},
      {k:'national_id',t:'شناسه ملی'},
      {k:'province_name',t:'استان'},
      {k:'city_name',t:'شهر'},
      {k:'production_site_type',t:'نوع سایت تولیدی'},
      {k:'manufacturing_industry_type',t:'نوع صنعت تولیدی'},
      {k:'postal_code',t:'کد پستی'},
      {k:'phone_raw',t:'تلفن'},
      {k:'email',t:'پست الکترونیکی'},
      {k:'manager_name_fa',t:'مدیرعامل'},
      {k:'manager_mobile',t:'شماره همراه'}
    ],
    filters:[
      {label:'نام واحد تولیدی',id:'factory_name_fa',type:'text'},
      {label:'شناسه ملی',id:'national_id',type:'text'},
      {label:'استان',id:'province_name',type:'text'},
      {label:'شهر',id:'city_name',type:'text'},
      {label:'نوع سایت تولیدی',id:'production_site_type',type:'text'},
      {label:'نوع صنعت تولیدی',id:'manufacturing_industry_type',type:'text'},
      {label:'کد پستی',id:'postal_code',type:'text'},
      {label:'تلفن',id:'phone_raw',type:'text'},
      {label:'پست الکترونیکی',id:'email',type:'text'},
      {label:'مدیرعامل',id:'manager_name_fa',type:'text'},
      {label:'شماره همراه',id:'manager_mobile',type:'text'}
    ]
  },
  source: {
    endpoint:'search_source.php',
    title:'ثبت منبع',
    columns:[
      {k:'source_code',t:'کد منبع'},
      {k:'status_fa',t:'وضعیت'},
      {k:'manufacturer_name_fa',t:'تولیدکننده'},
      {k:'production_line_name_fa',t:'نام فارسی خط تولید'},
      {k:'group_category',t:'گروه و دسته مرتبط با خط'},
      {k:'file_number',t:'شماره پرونده'},
      {k:'issue_datetime_raw',t:'تاریخ صدور'},
      {k:'expire_datetime_raw',t:'تاریخ انقضا'},
      {k:'technical_committee_datetime_raw',t:'تاریخ کمیته فنی'},
      {k:'technical_committee_number',t:'شماره کمیته فنی'}
    ],
    supportsLatest:true,
    filters:[
      {label:'کد منبع',id:'source_code',type:'text'},
      {label:'وضعیت',id:'status_fa',type:'select',options:['فعال','غیرفعال','منقضی']},
      {label:'تولیدکننده',id:'manufacturer_name_fa',type:'text'},
      {label:'نام فارسی خط تولید',id:'production_line_name_fa',type:'text'},
      {label:'گروه و دسته مرتبط با خط',id:'group_category',type:'text'},
      {label:'شماره پرونده',id:'file_number',type:'text'},
      {label:'تاریخ صدور',id:'issue_datetime_raw',type:'text'},
      {label:'تاریخ انقضا',id:'expire_datetime_raw',type:'text'},
      {label:'تاریخ کمیته فنی',id:'technical_committee_datetime_raw',type:'text'},
      {label:'شماره کمیته فنی',id:'technical_committee_number',type:'text'}
    ]
  },
  irc: {
    endpoint:'search_irc.php',
    title:'IRC',
    columns:[
      {k:'irc_code',t:'IRC'},
      {k:'status_fa',t:'وضعیت'},
      {k:'product_trade_name_fa',t:'نام تجاری'},
      {k:'issue_datetime_raw',t:'تاریخ صدور'},
      {k:'mother_license_code',t:'کد پروانه مادری'},
      {k:'license_holder_name_fa',t:'صاحب پروانه'},
      {k:'manufacturer_name_fa',t:'تولیدکننده'},
      {k:'product_generic_name_fa',t:'نام عمومی فرآورده'},
      {k:'category_group_code',t:'شناسه گروه و دسته'},
      {k:'first_issue_datetime_raw',t:'تاریخ اولین صدور'},
      {k:'expire_datetime_raw',t:'تاریخ انقضا'},
      {k:'committee_letter_number',t:'شماره کمیته'},
      {k:'committee_datetime_raw',t:'تاریخ کمیته'}
    ],
    supportsLatest:true,
    filters:[
      {label:'IRC',id:'irc_code',type:'text'},
      {label:'وضعیت',id:'status_fa',type:'select',options:['فعال','غیرفعال','منقضی']},
      {label:'نام تجاری',id:'product_trade_name_fa',type:'text'},
      {label:'تاریخ صدور',id:'issue_datetime_raw',type:'text'},
      {label:'کد پروانه مادری',id:'mother_license_code',type:'text'},
      {label:'صاحب پروانه',id:'license_holder_name_fa',type:'text'},
      {label:'تولیدکننده',id:'manufacturer_name_fa',type:'text'},
      {label:'نام عمومی فرآورده',id:'product_generic_name_fa',type:'text'},
      {label:'شناسه گروه و دسته',id:'category_group_code',type:'text'},
      {label:'تاریخ اولین صدور',id:'first_issue_datetime_raw',type:'text'},
      {label:'تاریخ انقضا',id:'expire_datetime_raw',type:'text'},
      {label:'شماره کمیته',id:'committee_letter_number',type:'text'},
      {label:'تاریخ کمیته',id:'committee_datetime_raw',type:'text'}
    ]
  },
  tech: {
    endpoint:'search_tech.php',
    title:'مسئول فنی',
    columns:[
      {k:'full_name_fa',t:'نام و نام خانوادگی'},
      {k:'company_name_fa',t:'نام شرکت'},
      {k:'license_number',t:'شماره پروانه'},
      {k:'ttac_expire_raw',t:'تاریخ انقضا TTAC'},
      {k:'status_fa',t:'وضعیت'}
    ],
    supportsLatest:true,
    filters:[
      {label:'نام و نام خانوادگی',id:'full_name_fa',type:'text'},
      {label:'نام شرکت',id:'company_name_fa',type:'text'},
      {label:'شماره پروانه',id:'license_number',type:'text'},
      {label:'تاریخ انقضا TTAC',id:'ttac_expire_raw',type:'text'},
      {label:'وضعیت',id:'status_fa',type:'select',options:['فعال','غیرفعال']}
    ]
  }
};

let activeDataset='factories';
let currentFilterIndex=0;
let currentPage=1;

function init(){
  qsa('.dataset-btn').forEach((btn, idx)=>{
    btn.addEventListener('click',()=>{
      activeDataset=btn.dataset.tab;
      currentPage=1;
      currentFilterIndex=0;
      qsa('.dataset-btn').forEach(b=>b.classList.remove('active'));
      btn.classList.add('active');
      renderFilters();
      clearResults();
    });
  });
  qs('#searchBtn').addEventListener('click',()=>{ currentPage=1; fetchData(); });
  qs('#perPage').addEventListener('change',()=>{ currentPage=1; fetchData(); });
  renderFilters();
}

function renderFilters(){
  const wrap=qs('#filter-panel');
  wrap.innerHTML='';
  Object.keys(tabsMap).forEach(tab=>{
    const t = tabsMap[tab];
    const active = (tab===activeDataset);

    let filters = t.filters;
    let selectedIdx = active ? currentFilterIndex : 0;
    let selectedFilter = filters[selectedIdx];

    let filterDropdown = `<select class="filter-dropdown" id="dd-${tab}">` +
      filters.map((f,idx)=>`<option value="${idx}"${idx===selectedIdx?' selected':''}>${f.label}</option>`).join('') +
      `</select>`;

    let filterInput = '';
    if(selectedFilter.type==='select'){
      filterInput = `<select class="filter-input" id="fi-${tab}-${selectedFilter.id}">
        <option value="">انتخاب ${selectedFilter.label}</option>
        ${selectedFilter.options.map(o=>`<option value="${o}">${o}</option>`).join('')}
      </select>`;
    }else{
      filterInput = `<input class="filter-input" type="${selectedFilter.type||'text'}" id="fi-${tab}-${selectedFilter.id}" placeholder="${selectedFilter.label} ...">`;
    }

    // فقط برای دیتاست فعال: سرچ کلی و آخرین نسخه
    let extra = '';
    if(active){
      extra += `<div style="margin-top:11px;">
        <label style="color:#059669;font-weight:700;">جستجو کلی</label>
        <input type="text" id="q" class="filter-input" placeholder="عبارت ...">
      </div>`;
      if(t.supportsLatest){
        extra += `<div style="margin-top:11px;">
          <label style="color:#059669;font-weight:700;">آخرین نسخه</label>
          <select id="latest" class="filter-input"><option value="1">بله</option><option value="0">خیر</option></select>
        </div>`;
      }
    }

    wrap.insertAdjacentHTML('beforeend',`
      <div class="filter-box${active?' active':''}">
        <div class="filter-title">${t.title}</div>
        ${filterDropdown}
        <div id="input-panel-${tab}">${filterInput}</div>
        ${extra}
      </div>
    `);

    // کنترل منوی آبشاری هر دیتاست
    setTimeout(()=>{
      const dd = qs(`#dd-${tab}`);
      if(dd){
        dd.onchange = (e)=>{
          if(active){
            currentFilterIndex = parseInt(e.target.value);
            renderFilters();
          }
        };
      }
    },10);
  });
}

function buildQuery(){
  const params=new URLSearchParams();
  const tab=tabsMap[activeDataset];
  if(tab && tab.filters){
    let selectedFilter = tab.filters[currentFilterIndex];
    let val = qs(`#fi-${activeDataset}-${selectedFilter.id}`)?.value?.trim();
    if(val) params.append(selectedFilter.id,val);
  }
  const q=qs('#q')?.value?.trim();
  if(q) params.append('q',q);
  if(qs('#latest')) params.append('latest', qs('#latest').value);
  params.append('page',currentPage);
  params.append('per_page',qs('#perPage').value);
  return params.toString();
}

async function fetchData(){
  const tab=tabsMap[activeDataset];
  if(!tab){ return; }
  const query=buildQuery();
  qs('#results').innerHTML='<div style="padding:20px;text-align:center;font-size:13px;color:#777">در حال دریافت...</div>';
  try{
    const res=await fetch(`../api/${tab.endpoint}?${query}`);
    const js=await res.json();
    renderTable(js, tab);
  }catch(e){
    toast('خطا در ارتباط: '+e.message,'error');
  }
}

function renderTable(data,tab){
  const cols=tab.columns;
  let html='<table class="table-clean"><thead><tr>';
  cols.forEach(c=> html+=`<th>${c.t}</th>`);
  html+='</tr></thead><tbody>';
  if(!data.rows || !data.rows.length){
    html+='<tr><td colspan="'+cols.length+'" style="text-align:center;color:#777;font-size:13px;">موردی یافت نشد</td></tr>';
  }else{
    data.rows.forEach(r=>{
      html+='<tr>';
      cols.forEach(c=>{
        let v=r[c.k];
        if(v==null || v==='') v='-';
        html+='<td>'+escapeHtml(String(v))+'</td>';
      });
      html+='</tr>';
    });
  }
  html+='</tbody></table>';
  html+=paginationBar(data.total, data.per_page, data.page);
  qs('#results').innerHTML=html;
  bindPagination();
}

function paginationBar(total, per, page){
  if(total<=per) return '';
  const pages=Math.ceil(total/per);
  let buf='<div class="pagination" style="display:flex;gap:6px;flex-wrap:wrap;margin-top:12px;">';
  const start=Math.max(1,page-2);
  const end=Math.min(pages,page+2);
  if(page>1) buf+=`<button data-page="${page-1}" class="btn-outline" style="padding:4px 12px;font-size:12px;">قبلی</button>`;
  for(let p=start;p<=end;p++){
    buf+=`<button data-page="${p}" class="btn ${p===page?'':'btn-outline'}" style="padding:4px 12px;font-size:12px;">${p}</button>`;
  }
  if(page<pages) buf+=`<button data-page="${page+1}" class="btn-outline" style="padding:4px 12px;font-size:12px;">بعدی</button>`;
  buf+='</div>';
  return buf;
}
function bindPagination(){
  qsa('.pagination button').forEach(b=>{
    b.addEventListener('click',()=>{
      currentPage=parseInt(b.dataset.page,10);
      fetchData();
    });
  });
}
function clearResults(){ qs('#results').innerHTML=''; }

function escapeHtml(s){
  return s.replace(/[&<>"']/g,c=>({ '&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;' }[c]));
}

document.addEventListener('DOMContentLoaded', init);
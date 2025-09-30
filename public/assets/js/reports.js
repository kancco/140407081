import {toast, qs} from './ui-common.js';

// لیبل‌های کارخانه (بدون نوع شرکت)
const factoryLabels = {
  factory_name_fa: "نام واحد تولیدی",
  national_id: "شناسه ملی",
  province_name: "استان",
  city_name: "شهر",
  production_site_type: "نوع سایت تولیدی",
  manufacturing_industry_type: "نوع صنعت تولیدی",
  postal_code: "کد پستی",
  phone_raw: "تلفن",
  email: "پست الکترونیکی",
  manager_name_fa: "مدیرعامل",
  manager_mobile: "شماره همراه"
};

const factoryCols = [
  "factory_name_fa",
  "national_id",
  "province_name",
  "city_name",
  "production_site_type",
  "manufacturing_industry_type",
  "postal_code",
  "phone_raw",
  "email",
  "manager_name_fa",
  "manager_mobile"
];

const fieldLabels = {
  irc_code: "IRC",
  status_fa: "وضعیت",
  product_trade_name_fa: "نام تجاری",
  issue_datetime_raw: "تاریخ صدور",
  mother_license_code: "کد پروانه مادری",
  license_holder_name_fa: "صاحب پروانه",
  manufacturer_name_fa: "تولیدکننده",
  product_generic_name_fa: "نام عمومی فرآورده",
  category_group_code: "شناسه گروه و دسته",
  first_issue_datetime_raw: "تاریخ اولین صدور",
  expire_datetime_raw: "تاریخ انقضا",
  committee_letter_number: "شماره کمیته",
  committee_datetime_raw: "تاریخ کمیته",
  source_code: "کد منبع",
  production_site_name_fa: "تولیدکننده",
  production_line_name_fa: "نام فارسی خط تولید",
  group_category: "گروه و دسته مرتبط با خط",
  file_number: "شماره پرونده",
  technical_committee_datetime_raw: "تاریخ کمیته فنی",
  technical_committee_number: "شماره کمیته فنی",
  full_name_fa: "نام و نام خانوادگی",
  company_name_fa: "نام شرکت",
  license_number: "شماره پروانه",
  ttac_expire_raw: "تاریخ انقضا TTAC"
};

const ircCols = [
  'irc_code',
  'status_fa',
  'product_trade_name_fa',
  'issue_datetime_raw',
  'mother_license_code',
  'license_holder_name_fa',
  'manufacturer_name_fa',
  'product_generic_name_fa',
  'category_group_code',
  'first_issue_datetime_raw',
  'expire_datetime_raw',
  'committee_letter_number',
  'committee_datetime_raw'
];

// ستون‌های عددی طولانی که باید فرمت text و اعداد فارسی داشته باشند
const numericFields = [
  'irc_code', 'mother_license_code', 'national_id', 'license_number', 'manager_mobile', 'phone_raw',
  'ttac_expire_raw', 'file_number', 'source_code', 'technical_committee_number', 'committee_letter_number',
  'committee_datetime_raw', 'expire_datetime_raw', 'technical_committee_datetime_raw', 'postal_code'
];

function toPersianDigits(str) {
  if(!str) return str;
  return String(str).replace(/\d/g, d => '۰۱۲۳۴۵۶۷۸۹'[d]);
}

function formatDate(val) {
  if (!val) return '-';
  let m = val.match(/(\d{4})[\/\-\.](\d{2})[\/\-\.](\d{2})/);
  if (m) return toPersianDigits(`${m[1]}/${m[2]}/${m[3]}`);
  m = val.match(/(13\d{2}|14\d{2})[\/\-\.](\d{1,2})[\/\-\.](\d{1,2})/);
  if (m) return toPersianDigits(`${m[1]}/${m[2].padStart(2,'0')}/${m[3].padStart(2,'0')}`);
  return toPersianDigits(val);
}

function dateToComparable(val) {
  if (!val) return 0;
  let s = String(val).replace(/[۰-۹]/g, d => '0123456789'['۰۱۲۳۴۵۶۷۸۹'.indexOf(d)]);
  s = s.replace(/-/g, '/').replace(/\./g, '/');
  let m = s.match(/^(13\d{2}|14\d{2}|\d{4})\/(\d{1,2})\/(\d{1,2})$/);
  if(m) return Number(m[1] + m[2].padStart(2,'0') + m[3].padStart(2,'0'));
  return 0;
}

function gregorianToJalali(gy, gm, gd) {
  var g_d_m = [0,31,59,90,120,151,181,212,243,273,304,334];
  var jy = (gy <= 1600) ? 0 : 979;
  gy -= (gy <= 1600) ? 621 : 1600;
  var gy2 = (gm > 2) ? (gy + 1) : gy;
  var days = (365 * gy) + Math.floor((gy2 + 3) / 4) - Math.floor((gy2 + 99) / 100)
      + Math.floor((gy2 + 399) / 400) - 80 + gd + g_d_m[gm - 1];
  jy += 33 * Math.floor(days / 12053);
  days %= 12053;
  jy += 4 * Math.floor(days / 1461);
  days %= 1461;
  if (days > 365) {
    jy += Math.floor((days - 1) / 365);
    days = (days - 1) % 365;
  }
  var jm = (days < 186) ? 1 + Math.floor(days / 31) : 7 + Math.floor((days - 186) / 30);
  var jd = 1 + ((days < 186) ? (days % 31) : ((days - 186) % 30));
  return [jy, jm, jd];
}

function getTodayJalaliStr() {
  const d = new Date();
  const [jy, jm, jd] = gregorianToJalali(d.getFullYear(), d.getMonth() + 1, d.getDate());
  return `${toPersianDigits(jy)}/${toPersianDigits(String(jm).padStart(2, '0'))}/${toPersianDigits(String(jd).padStart(2, '0'))}`;
}

function extractJalaliDate(str) {
  let m = String(str).match(/(1[34]\d{2})[\/\-\.](\d{1,2})[\/\-\.](\d{1,2})/);
  if (m) return `${m[1]}/${m[2].padStart(2,'0')}/${m[3].padStart(2,'0')}`;
  return '';
}

const todayComparable = dateToComparable(getTodayJalaliStr());

function groupRowsBySourceAndLine(rows) {
  const groupMap = new Map();
  rows.forEach(row => {
    const key = `${row.source_code}|${row.production_line_name_fa}`;
    if(!groupMap.has(key)) {
      groupMap.set(key, {...row, _group_categories: [row.group_category]});
    } else {
      const item = groupMap.get(key);
      if (row.group_category && !item._group_categories.includes(row.group_category))
        item._group_categories.push(row.group_category);
    }
  });
  return Array.from(groupMap.values()).map(item => ({
    ...item,
    group_category: item._group_categories.join('، ')
  }));
}

function getDynamicCounts(rows, field) {
  const map = {};
  rows.forEach(r => {
    const val = (r[field] || '').trim();
    if(!val) return;
    map[val] = (map[val] || 0) + 1;
  });
  return Object.entries(map).map(([key, count]) => ({key, count}));
}

// استایل فیلتر فعال
const style = document.createElement('style');
style.innerHTML = `
.active-stat {
  font-weight: bold;
  color: #1976d2 !important;
  background: #e3f2fd;
  border-radius: 4px;
  padding: 0 4px;
}
.active-stat.expired {
  color: #b71c1c !important;
  background: #ffebee;
}
`;
document.head.appendChild(style);

// دکمه اکسل و پرینت کنار آمار
const getExcelBtn = (tableId) =>
  `<button class="excel-btn" id="export-${tableId}-excel" title="خروجی اکسل" style="margin-right: 8px; background:none; border:none; cursor:pointer; vertical-align:middle; padding:0;">
    <img src="https://cosmetics.kanc.ir/assets/img/export-excel.svg" alt="Excel" style="width:20px;height:20px;">
  </button>`;
const getPrintBtn = (tableId) =>
  `<button class="print-btn" id="print-${tableId}-btn" title="چاپ" style="margin-right: 8px; background:none; border:none; cursor:pointer; vertical-align:middle; padding:0;">
    <img src="https://cosmetics.kanc.ir/assets/img/printer.svg" alt="Print" style="width:20px;height:20px;">
  </button>`;

function setActiveStat(statId, expired = false) {
  document.querySelectorAll('.stat-link').forEach(el => {
    el.classList.remove('active-stat', 'expired');
  });
  const el = document.getElementById(statId);
  if (el) {
    el.classList.add('active-stat');
    if (expired) el.classList.add('expired');
  }
}

function buildFactoriesSection(data) {
  const rows = data.rows || [];
  const total = toPersianDigits(rows.length);

  const typeStatsArr = getDynamicCounts(rows, 'production_site_type');
  let tableId = "factory-report-table";
  let excelExportBtn = getExcelBtn(tableId);
  let printBtn = getPrintBtn(tableId);

  let statsHtml = `<span style="font-size:13px;color:#2563eb;font-weight:400;">`
    + `<span class="stat-link active-stat" style="cursor:pointer;text-decoration:underline;" id="show-all-${tableId}">تعداد کل: ${total}</span>`
    + (typeStatsArr.length > 0 ? ' ، ' + typeStatsArr.map((item, idx) =>
      `<span class="stat-link" style="cursor:pointer;text-decoration:underline;" id="show-type-${tableId}-${idx}">${item.key}: ${toPersianDigits(item.count)}</span>`).join(' ، ') : '')
    + `</span>`;

  let html = `<div class="surface">
    <div style="display:flex;align-items:center;justify-content:space-between;">
      <h3 style="margin:0;">گزارش واحدهای تولیدی ${statsHtml}</h3>
      <div style="display:flex;align-items:center;gap:0;">${excelExportBtn}${printBtn}</div>
    </div>
    <div style="max-height:400px;overflow:auto;">
      <table class="table-clean" id="${tableId}" style="width:100%;text-align:center;">
        <thead><tr>
          <th style="text-align:center;">ردیف</th>
          ${factoryCols.map(c => `<th style="text-align:center;">${factoryLabels[c] || c}</th>`).join('')}
        </tr></thead>
        <tbody>
          ${
            rows.length === 0
            ? `<tr><td colspan="${factoryCols.length + 1}" style="text-align:center;color:#777;font-size:13px;">داده‌ای نیست</td></tr>`
            : rows.map((r, i) => `<tr>
                <td style="text-align:center;">${toPersianDigits(i + 1)}</td>
                ${factoryCols.map(c => {
                  let v = r[c] ?? '-';
                  if(v === "") v = '-';
                  v = toPersianDigits(v);
                  return `<td style="text-align:center;">${v}</td>`;
                }).join('')}
              </tr>`).join('')
          }
        </tbody>
      </table>
    </div>
  </div>`;

  setTimeout(() => {
    const table = document.getElementById(tableId);

    const btn = document.getElementById('export-factory-report-table-excel');
    if (btn) btn.onclick = function() { exportTableToExcel(tableId, 'factory_report'); };

    const printBtnEl = document.getElementById('print-factory-report-table-btn');
    if (printBtnEl) printBtnEl.onclick = function() { printTable(tableId, 'گزارش واحدهای تولیدی'); };

    // تعداد کل
    const showAllBtn = document.getElementById(`show-all-${tableId}`);
    if (showAllBtn) showAllBtn.onclick = function() {
      Array.from(table.querySelectorAll('tbody tr')).forEach(tr => tr.style.display = '');
      setActiveStat(`show-all-${tableId}`);
    };
    // نوع سایت تولیدی
    typeStatsArr.forEach((item, idx) => {
      const typeBtn = document.getElementById(`show-type-${tableId}-${idx}`);
      if (typeBtn) typeBtn.onclick = function() {
        Array.from(table.querySelectorAll('tbody tr')).forEach(tr => {
          let typeIndex = factoryCols.findIndex(c => c === 'production_site_type');
          if (typeIndex > -1) {
            let td = tr.children[typeIndex + 1];
            if (td && td.textContent.trim() === item.key) tr.style.display = '';
            else tr.style.display = 'none';
          }
        });
        setActiveStat(`show-type-${tableId}-${idx}`);
      };
    });
  }, 0);

  return html;
}

function buildSection(title, data, cols, doGroup, rawRows){
  let rows = data.rows;
  if(doGroup) rows = groupRowsBySourceAndLine(rows);

  const totalRaw = rawRows ? rawRows.length : rows.length;

  let statusStatsArr = [];
  let expiredRowsCount = 0;
  let expireField = cols.includes('expire_datetime_raw') ? 'expire_datetime_raw' : null;

  let tableId = '';
  if (title.includes('پروانه ثبت منبع')) tableId = 'source-report-table';
  if (title.includes('گزارش مسئولین فنی')) tableId = 'tech-report-table';
  if (title.includes('گزارش پروانه IRC')) tableId = 'irc-report-table';
  let excelExportBtn = tableId ? getExcelBtn(tableId) : '';
  let printBtn = tableId ? getPrintBtn(tableId) : '';

  if (title.includes('پروانه ثبت منبع') || title.includes('گزارش مسئولین فنی') || title.includes('گزارش پروانه IRC')) {
    statusStatsArr = getDynamicCounts(rawRows || rows, 'status_fa');
  }

  let htmlRows = '';
  expiredRowsCount = 0;
  if(!rows || !rows.length){
    htmlRows = `<tr><td colspan="${cols.length + 1}" style="text-align:center;color:#777;font-size:13px;">داده‌ای نیست</td></tr>`;
  } else {
    htmlRows = rows.map((r, i) => {
      let trClass = '';
      let expireComparable = 0;
      let expireVal = expireField ? r[expireField] : null;
      if (expireVal) {
        let justDate = extractJalaliDate(expireVal);
        let raw = String(justDate).replace(/[۰-۹]/g, d => '0123456789'['۰۱۲۳۴۵۶۷۸۹'.indexOf(d)]);
        raw = raw.replace(/-/g, '/').replace(/\./g, '/');
        let m = raw.match(/^(13\d{2}|14\d{2}|\d{4})\/(\d{1,2})\/(\d{1,2})$/);
        if (m) expireComparable = Number(m[1] + m[2].padStart(2,'0') + m[3].padStart(2,'0'));
      }
      if (expireComparable > 0 && expireComparable < todayComparable){
        trClass = 'expired-row';
        expiredRowsCount++;
      }
      let tds = `<td style="text-align:center;">${toPersianDigits(i + 1)}</td>`;
      tds += cols.map(c => {
        let v = r[c];
        if(v == null || v === "") v = '-';
        if(c.toLowerCase().includes('date')) v = formatDate(v);
        else v = toPersianDigits(v);
        if (numericFields.includes(c) && v !== '-') {
          return `<td style="mso-number-format:'\\@';text-align:center;">${v}</td>`;
        }
        return `<td style="text-align:center;">${v}</td>`;
      }).join('');
      return `<tr${trClass ? ` class="${trClass}"` : ''}>${tds}</tr>`;
    }).join('');
  }

  let statsHtml = `<span style="font-size:13px;color:#2563eb;font-weight:400;">`
    + `<span class="stat-link active-stat" style="cursor:pointer;text-decoration:underline;" id="show-all-${tableId}">تعداد کل: ${toPersianDigits(totalRaw)}</span>`
    + (statusStatsArr.length > 0 ? ' ، ' + statusStatsArr.map(({key, count}, idx) =>
        `<span class="stat-link" style="cursor:pointer;text-decoration:underline;" data-status="${key}" id="show-status-${tableId}-${idx}">${key}: ${toPersianDigits(count)}</span>`
      ).join(' ، ') : '')
    + (expireField ? ` ، <span class="stat-link" style="color:#d32f2f;cursor:pointer;text-decoration:underline;" id="show-expired-${tableId}">منقضی: ${toPersianDigits(expiredRowsCount)}</span>` : '')
    + `</span>`;

  let html = `<div class="surface">
    <div style="display:flex;align-items:center;justify-content:space-between;">
      <h3 style="margin:0;">${title} ${statsHtml}</h3>
      <div style="display:flex;align-items:center;gap:0;">${excelExportBtn}${printBtn}</div>
    </div>
    <div style="max-height:400px;overflow:auto;">
      <table class="table-clean" ${tableId ? `id="${tableId}"` : ''} style="width:100%;text-align:center;">
        <thead><tr>
          <th style="text-align:center;">ردیف</th>
          ${cols.map(c => `<th style="text-align:center;">${fieldLabels[c] || c}</th>`).join('')}
        </tr></thead><tbody>`;
  html += htmlRows;
  html += '</tbody></table></div></div>';

  setTimeout(() => {
    if (tableId) {
      const table = document.getElementById(tableId);

      const btn = document.getElementById(`export-${tableId}-excel`);
      if (btn) btn.onclick = function() { exportTableToExcel(tableId, tableId.replace('-table','')); };

      const printBtnEl = document.getElementById(`print-${tableId}-btn`);
      if (printBtnEl) printBtnEl.onclick = function() { printTable(tableId, title); };

      // نمایش همه
      const showAllBtn = document.getElementById(`show-all-${tableId}`);
      if (showAllBtn) showAllBtn.onclick = function() {
        Array.from(table.querySelectorAll('tbody tr')).forEach(tr => tr.style.display = '');
        setActiveStat(`show-all-${tableId}`);
      };
      // وضعیت‌ها
      statusStatsArr.forEach(({key}, idx) => {
        const statusBtn = document.getElementById(`show-status-${tableId}-${idx}`);
        if (statusBtn) {
          statusBtn.onclick = function() {
            Array.from(table.querySelectorAll('tbody tr')).forEach(tr => {
              let statusIndex = cols.findIndex(c => c === 'status_fa');
              if (statusIndex > -1) {
                let td = tr.children[statusIndex + 1];
                if (td && td.textContent.trim() === key) tr.style.display = '';
                else tr.style.display = 'none';
              }
            });
            setActiveStat(`show-status-${tableId}-${idx}`);
          };
        }
      });
      // منقضی‌ها
      const expiredBtn = document.getElementById(`show-expired-${tableId}`);
      if (expiredBtn) {
        expiredBtn.onclick = function() {
          Array.from(table.querySelectorAll('tbody tr')).forEach(tr => {
            if(tr.classList.contains('expired-row')) tr.style.display = '';
            else tr.style.display = 'none';
          });
          setActiveStat(`show-expired-${tableId}`, true);
        };
      }
    }
  }, 0);

  return html;
}

// چاپ جدول با تکرار سرستون هر صفحه و اعداد فارسی
function printTable(tableId, title) {
  const table = document.getElementById(tableId);
  if (!table) return;
  let clone = table.cloneNode(true);
  clone.querySelectorAll('td,th').forEach(el => el.innerText = toPersianDigits(el.innerText));
  let html = `
    <style>
      @media print {
        table { page-break-inside:auto; }
        tr { page-break-inside:avoid; page-break-after:auto; }
        thead { display:table-header-group; }
        tfoot { display:table-footer-group; }
      }
      body { direction:rtl; font-family:tahoma,iransans,sans-serif; }
      h2 { margin-bottom:14px; }
      table { border-collapse:collapse;width:100%; }
      th, td { border:1px solid #888; padding:5px 7px; text-align:center; font-size:13px;}
      th { background:#f4f6fa; }
      .expired-row { background:#ffeaea; }
    </style>
    <h2>${title}</h2>
    ${clone.outerHTML}
  `;
  let win = window.open('', '', 'width=900,height=700');
  win.document.write(html);
  win.document.close();
  win.focus();
  win.print();
  setTimeout(() => win.close(), 500);
}

function exportTableToExcel(tableId, filename) {
  const table = document.getElementById(tableId);
  if(!table) return;

  let clone = table.cloneNode(true);
  let ths = clone.querySelectorAll('thead th');
  let headers = Array.from(ths).map(th => th.innerText.trim());
  clone.querySelectorAll('tbody tr').forEach(tr => {
    Array.from(tr.children).forEach((td, idx) => {
      let field = headers[idx-1]; // idx-1 چون اولین ستون "ردیف" است
      if(idx > 0 && numericFields.includes(field) && td.innerText !== '-') {
        td.setAttribute("style", "mso-number-format:'\\@';text-align:center;");
        td.innerText = toPersianDigits(td.innerText);
      }
    });
  });
  let html = clone.outerHTML.replace(/ /g, '%20');
  let uri = 'data:application/vnd.ms-excel,';
  let downloadLink = document.createElement("a");
  downloadLink.href = uri + html;
  downloadLink.download = filename + ".xls";
  document.body.appendChild(downloadLink);
  downloadLink.click();
  document.body.removeChild(downloadLink);
}

async function loadSummaries(){
  qs('#report-area').innerHTML = '<div style="padding:18px;text-align:center;color:#777;font-size:13px;">در حال دریافت...</div>';
  let factory = {}, src = {}, tech = {}, irc = {};
  try{
    factory = await fetch('/api/search_factories.php?latest=1&per_page=1000').then(r=>r.json());
  }catch(e){
    factory = {rows:[]}; toast('خطا در گزارش واحدهای تولیدی: '+e.message,'error');
  }
  try{
    src = await fetch('/api/search_source.php?per_page=10000').then(r=>r.json());
  }catch(e){
    src = {rows:[]}; toast('خطا در گزارش منبع: '+e.message,'error');
  }
  try{
    tech = await fetch('/api/search_tech.php?latest=1&per_page=1000').then(r=>r.json());
  }catch(e){
    tech = {rows:[]}; toast('خطا در گزارش مسئول فنی: '+e.message,'error');
  }
  try{
    irc = await fetch('/api/search_irc.php?per_page=2000').then(r=>r.json());
  }catch(e){
    irc = {rows:[]}; toast('خطا در گزارش IRC: '+e.message,'error');
  }
  qs('#report-area').innerHTML =
    buildFactoriesSection(factory)
    + buildSection('گزارش پروانه ثبت منبع', src, [
      'source_code','status_fa','production_site_name_fa','production_line_name_fa','group_category','file_number','issue_datetime_raw','expire_datetime_raw','technical_committee_datetime_raw','technical_committee_number'
    ], true, src.rows)
    + buildSection('گزارش مسئولین فنی', tech, [
      'full_name_fa','company_name_fa','license_number','ttac_expire_raw','status_fa'
    ], false, tech.rows)
    + buildSection('گزارش پروانه IRC', irc, ircCols, false, irc.rows);
}

document.addEventListener('DOMContentLoaded', loadSummaries);
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.102.0";

const SUPABASE_URL = "https://oxmjqjiqtocmvvchiwbg.supabase.co";
const SUPABASE_KEY = "sb_publishable_vaVsUHLqFTA_5ZldtRGK3A_yBKYoZlD";
const supabase = createClient(SUPABASE_URL, SUPABASE_KEY, {
  auth: { persistSession: true, autoRefreshToken: true, detectSessionInUrl: true }
});

const $ = (id) => document.getElementById(id);
let currentUser = null;
let sheepRows = [];

function message(id, text, error = false) {
  const node = $(id);
  if (!node) return;
  node.textContent = text || "";
  node.style.color = error ? "#a33b32" : "#55715f";
}
function normalizeLibyanPhone(value) {
  let phone = String(value || "").replace(/[\s()-]/g, "");
  if (phone.startsWith("00")) phone = "+" + phone.slice(2);
  if (phone.startsWith("0")) phone = "+218" + phone.slice(1);
  else if (phone.startsWith("218")) phone = "+" + phone;
  return phone;
}
function categoryLabel(value) {
  return ({ ram:"فحل", ewe:"نعجة", ram_lamb:"حولي", ewe_lamb:"حايل فطيمة", lamb:"مولود", other:"أخرى" })[value] || value || "—";
}
function sexLabel(value) { return value === "male" ? "ذكر" : "أنثى"; }
function healthLabel(value) {
  return ({ good:"جيدة", monitor:"تحت المراقبة", sick:"مريضة", treated:"تحت العلاج", deceased:"نافقة", sold:"مباعة" })[value] || value || "—";
}
function ageText(date) {
  if (!date) return "العمر غير محدد";
  const birth = new Date(date + "T00:00:00");
  if (Number.isNaN(birth.getTime())) return "العمر غير محدد";
  const now = new Date();
  let months = (now.getFullYear() - birth.getFullYear()) * 12 + now.getMonth() - birth.getMonth();
  if (now.getDate() < birth.getDate()) months--;
  if (months < 0) return "تاريخ الميلاد غير صحيح";
  if (months < 12) return months + " شهر";
  const years = Math.floor(months / 12);
  const rest = months % 12;
  return years + " سنة" + (rest ? " و" + rest + " شهر" : "") + (months >= 13 ? " — سنة كاملة ودخل في الثانية" : "");
}
function showApp(user) {
  currentUser = user;
  $("login").classList.add("hidden");
  $("app").classList.remove("hidden");
  loadSheep();
}
function showLogin() {
  currentUser = null;
  $("app").classList.add("hidden");
  $("login").classList.remove("hidden");
}
async function loadSheep() {
  if (!currentUser) return;
  $("animals").textContent = "جارٍ تحميل سجل أغنامك…";
  const { data, error } = await supabase
    .from("rahba_sheep")
    .select("id,animal_code,name,sex,category,breed,birth_date,weight_kg,health_status,notes,created_at")
    .eq("owner_id", currentUser.id)
    .order("created_at", { ascending: false });
  if (error) {
    $("animals").textContent = "تعذر تحميل السجل: " + error.message;
    return;
  }
  sheepRows = data || [];
  renderSheep();
}
function renderSheep() {
  const query = ($("search").value || "").trim().toLocaleLowerCase();
  const rows = sheepRows.filter((s) =>
    [s.animal_code, s.name, s.breed, s.notes, categoryLabel(s.category)]
      .filter(Boolean).join(" ").toLocaleLowerCase().includes(query)
  );
  $("total").textContent = sheepRows.filter(s => !["sold","deceased"].includes(s.health_status)).length;
  $("rams").textContent = sheepRows.filter(s => s.category === "ram" && s.health_status !== "sold" && s.health_status !== "deceased").length;
  const unwell = sheepRows.some(s => ["sick","treated","monitor"].includes(s.health_status));
  $("health").textContent = sheepRows.length ? (unwell ? "تحتاج متابعة" : "جيدة") : "لا توجد بيانات";
  $("count").textContent = rows.length + " رأس";
  const host = $("animals");
  host.replaceChildren();
  if (!rows.length) {
    const p = document.createElement("p");
    p.className = "muted";
    p.textContent = query ? "لا توجد نتائج مطابقة للبحث." : "لا توجد رؤوس مسجلة بعد. ابدأ بإضافة أول رأس.";
    host.append(p);
    return;
  }
  for (const s of rows) {
    const item = document.createElement("article");
    item.className = "animal";
    const info = document.createElement("div");
    const title = document.createElement("strong");
    title.textContent = (s.name || "بدون اسم") + " · " + (s.animal_code || "دون رقم");
    const details = document.createElement("p");
    details.className = "muted";
    details.textContent = [categoryLabel(s.category), sexLabel(s.sex), ageText(s.birth_date), s.weight_kg ? s.weight_kg + " كغ" : "", s.breed || "", healthLabel(s.health_status)].filter(Boolean).join(" • ");
    info.append(title, details);
    item.append(info);
    host.append(item);
  }
}
async function authenticate(signUp) {
  const phone = normalizeLibyanPhone($("phone").value);
  const password = $("password").value;
  if (!/^\+218\d{9}$/.test(phone)) {
    message("authMsg", "أدخل رقم ليبي صحيحًا، مثل 0912345678.", true);
    return;
  }
  if (password.length < 8) {
    message("authMsg", "كلمة المرور يجب ألا تقل عن 8 أحرف.", true);
    return;
  }
  $("loginBtn").disabled = true;
  $("signupBtn").disabled = true;
  message("authMsg", signUp ? "جارٍ إنشاء الحساب…" : "جارٍ التحقق من بيانات الدخول…");
  try {
    const result = signUp
      ? await supabase.auth.signUp({ phone, password })
      : await supabase.auth.signInWithPassword({ phone, password });
    if (result.error) throw result.error;
    if (result.data.session && result.data.user) {
      message("authMsg", "");
      showApp(result.data.user);
    } else if (signUp) {
      message("authMsg", "تم إرسال طلب إنشاء الحساب. إذا كان تأكيد الهاتف مفعّلًا، أكمل رمز الرسالة النصية ثم سجّل الدخول.");
    } else {
      throw new Error("لم يتم إنشاء جلسة دخول. تحقق من إعدادات تأكيد الهاتف في Supabase.");
    }
  } catch (e) {
    message("authMsg", e.message || "تعذر إتمام العملية.", true);
  } finally {
    $("loginBtn").disabled = false;
    $("signupBtn").disabled = false;
  }
}

$("loginBtn").addEventListener("click", () => authenticate(false));
$("signupBtn").addEventListener("click", () => authenticate(true));
$("password").addEventListener("keydown", e => { if (e.key === "Enter") authenticate(false); });
$("showAdd").addEventListener("click", () => $("addPanel").classList.toggle("hidden"));
$("cancelAdd").addEventListener("click", () => {
  $("addPanel").classList.add("hidden");
  message("saveMsg", "");
});
$("search").addEventListener("input", renderSheep);
$("logout").addEventListener("click", async () => {
  await supabase.auth.signOut();
  sheepRows = [];
  showLogin();
});
$("saveSheep").addEventListener("click", async () => {
  if (!currentUser) return;
  const animalCode = $("code").value.trim();
  if (!animalCode) {
    message("saveMsg", "اكتب رقم أو معرّف الرأس أولًا.", true);
    return;
  }
  const category = $("category").value;
  const sex = $("sex").value;
  if ((category === "ram" || category === "ram_lamb") && sex !== "male") {
    message("saveMsg", "تصنيف الفحل أو الحولي الذكر يتطلب اختيار ذكر.", true);
    return;
  }
  if ((category === "ewe" || category === "ewe_lamb") && sex !== "female") {
    message("saveMsg", "تصنيف النعجة أو الحايل الفطيمة يتطلب اختيار أنثى.", true);
    return;
  }
  const payload = {
    owner_id: currentUser.id,
    animal_code: animalCode,
    name: $("name").value.trim() || null,
    sex,
    category,
    birth_date: $("birth").value || null,
    weight_kg: $("weight").value ? Number($("weight").value) : null,
    health_status: $("status").value,
    breed: $("breed").value.trim() || null,
    notes: $("notes").value.trim() || null
  };
  $("saveSheep").disabled = true;
  message("saveMsg", "جارٍ حفظ الرأس في قاعدة البيانات…");
  const { error } = await supabase.from("rahba_sheep").insert(payload);
  $("saveSheep").disabled = false;
  if (error) {
    message("saveMsg", "لم يتم الحفظ: " + error.message, true);
    return;
  }
  ["code","name","birth","weight","breed","notes"].forEach(id => $(id).value = "");
  $("category").value = "lamb";
  $("sex").value = "female";
  $("status").value = "good";
  message("saveMsg", "تم حفظ الرأس بنجاح.");
  await loadSheep();
});

supabase.auth.getSession().then(({ data, error }) => {
  if (error) message("authMsg", error.message, true);
  if (data?.session?.user) showApp(data.session.user);
}).catch(e => message("authMsg", e.message, true));

supabase.auth.onAuthStateChange((event, session) => {
  if (event === "SIGNED_OUT") showLogin();
  if (session?.user && event === "SIGNED_IN") showApp(session.user);
});
